// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import 'contracts/polygon/deps/openzeppelin/utils/Context.sol';
import 'contracts/polygon/deps/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol';

/**
 * @title nTreasury - Multi-Signature Treasury Contract
 * @dev The nTreasury contract is designed as a multi-signature treasury, allowing a group of trustees to collectively
 *      manage and execute withdrawal requests. The contract provides a secure and decentralized mechanism for handling
 *      Ether and ERC-20 token withdrawals. Trustees are appointed by the admin and must collaboratively sign withdrawal
 *      requests to meet the required threshold for execution.
 *
 * @dev The contract is implemented using the Diamond Standard for Ethereum contracts, enabling modular and upgradable
 *      functionality through facets. The main facet in this contract is responsible for managing trustee access, creating
 *      and signing withdrawal requests, and executing signed requests.
 *
 * @dev The contract employs a node-style storage layout for efficient state management. It defines two main structs,
 *      `Request` to represent withdrawal requests, and `StorageTreasury` to organize the contract's storage variables.
 *
 * @dev The contract includes key access control mechanisms to enforce roles and permissions:
 *      - Admin: The contract admin has the authority to appoint and remove trustees, set the withdrawal threshold,
 *        and manage other administrative functions.
 *      - Trustee: Trustees are responsible for creating and signing withdrawal requests. They participate in the
 *        multi-signature process, collectively reaching the required threshold for request execution.
 *
 * @dev The contract emits various events to provide transparency and allow external observers to track important
 *      activities, such as changes in trustee status, creation of new withdrawal requests, trustee signatures, and
 *      successful execution of withdrawal requests.
 *
 * @dev Functions in this contract are designed to be called by other contracts or external actors in a controlled manner.
 *      Access control modifiers, such as `_onlyAdmin` and `_onlyTrustee`, are used to restrict certain functions to
 *      authorized addresses, ensuring the security and integrity of the contract.
 *
 * @dev This contract is meant to be used as part of a larger decentralized application (DApp) or system, where the
 *      multi-signature treasury functionality provided by nTreasury is a key component in managing and securing
 *      decentralized funds.
 *
 * ATTACK SURFACE
 * | claim
 * | setTreasuryTrustee
 * | request
 * | sign
 * | execute
 */
contract nTreasury is Context {

    /**
    * @notice Represents the storage pointer for the nTreasury contract's storage location within the terminal (diamond).
    *
    * @dev The `_TREASURY` constant serves as a unique identifier and storage pointer for locating the storage structure
    * of the nTreasury contract within the terminal (diamond architecture). It is a keccak256 hash of the string 'node.treasury',
    * providing a deterministic and secure way to access the storage slot associated with the nTreasury contract.
    *
    * @dev The storage slot identified by `_TREASURY` is used to store critical information such as trustee status, administrative
    * control, withdrawal requests, and other essential data required for the functionality of the nTreasury contract.
    *
    * @dev The use of a constant ensures consistency in accessing the storage slot across the contract's functions and allows for
    * efficient compilation and execution of the contract's logic.
    *
    * @dev This constant is internal, indicating that it is meant for internal use within the contract and should not be exposed or
    * modified by external contracts or users.
    *
    * @dev The keccak256 hash of 'node.treasury' ensures uniqueness and collision resistance, providing a secure and reliable
    * identifier for the storage slot associated with the nTreasury contract within the diamond architecture.
    *
    * @dev This comment provides clarity on the purpose and significance of the `_TREASURY` constant within the context of the
    * nTreasury contract's storage architecture.
    */
    bytes32 internal constant _TREASURY = keccak256('node.treasury');

    /**
    * @notice Represents a withdrawal request in the nTreasury contract.
    *
    * @dev The `Request` struct encapsulates the details of a withdrawal request initiated
    * by a trustee in the nTreasury contract. It includes information such as the destination
    * address, token details, withdrawal amount, signature status, and execution status.
    *
    * @param to The destination address for the withdrawal. It represents the Ethereum address
    *           to which the funds or tokens will be withdrawn upon successful execution of the request.
    *
    * @param tokenOut The token address (ERC-20) specified in the withdrawal request. If the address
    *                 is `address(0)`, it indicates a withdrawal of Ether (ETH). Otherwise, it represents
    *                 the specific ERC-20 token to be withdrawn.
    *
    * @param amountOut The amount to be withdrawn in the specified token. It represents the quantity
    *                  of funds or tokens requested for withdrawal.
    *
    * @param numSignatures The count of trustee signatures received for the withdrawal request.
    *                      It represents the number of trustees who have signed the request, indicating
    *                      progress toward the required threshold for execution.
    *
    * @param executed A boolean flag indicating whether the withdrawal request has been successfully
    *                 executed. When `true`, it means the requested funds or tokens have been transferred
    *                 to the destination address, and the request is considered fulfilled.
    *
    * @param hasSigned A mapping that tracks the signature status of trustees for the withdrawal request.
    *                  For each trustee's Ethereum address, it indicates whether the trustee has signed
    *                  the request (`true`) or not (`false`). This mapping facilitates quick checks for
    *                  duplicate signatures and ensures each trustee signs the request only once.
    *
    * @dev The `to` parameter represents the Ethereum address to which the funds or tokens will be withdrawn
    * upon successful execution of the withdrawal request. It is the recipient of the withdrawal.
    *
    * @dev The `tokenOut` parameter specifies the ERC-20 token to be withdrawn. If the address is `address(0)`,
    * it indicates a withdrawal of Ether (ETH). Otherwise, it represents the specific ERC-20 token.
    *
    * @dev The `amountOut` parameter indicates the quantity of funds or tokens to be withdrawn. It represents
    * the numerical value of the withdrawal amount.
    *
    * @dev The `numSignatures` parameter tracks the count of trustee signatures received for the withdrawal
    * request. It is used to calculate the current percentage of signatures relative to the total number
    * of trustees and determine whether the request has reached the required threshold for execution.
    *
    * @dev The `executed` parameter is a boolean flag that indicates whether the withdrawal request has been
    * successfully executed. When `true`, it means the requested funds or tokens have been transferred, and
    * the request is considered fulfilled.
    *
    * @dev The `hasSigned` mapping allows efficient tracking of trustee signatures for a given withdrawal request,
    * preventing duplicate signatures and ensuring each trustee signs the request only once.
    *
    * @dev This struct provides a comprehensive representation of a withdrawal request's state and progress
    * within the nTreasury contract, allowing efficient tracking and management of multi-signature withdrawals.
    */
    struct Request {
        address to;
        address tokenOut;
        uint amountOut;
        uint numSignatures;
        bool executed;
        mapping(address => bool) hasSigned;
    }

    /**
    * @notice Represents the storage structure for the nTreasury contract.
    *
    * @dev The `StorageTreasury` struct encapsulates the key storage elements
    * required for the functionality of the nTreasury contract.
    *
    * @param isTrustee A mapping that tracks the trustee status of Ethereum addresses.
    *                  For each address, it indicates whether the address has trustee
    *                  privileges (`true`) or not (`false`).
    *
    * @param trusteeCount The count of active trustees in the nTreasury contract.
    *                     It represents the current number of addresses with trustee
    *                     privileges. This count is dynamically updated when trustees
    *                     are added or removed.
    *
    * @param threshold The required threshold for executing a withdrawal request.
    *                  It represents the percentage of trustees' signatures required
    *                  for a withdrawal request to be considered valid and executable.
    *                  The threshold is a value between 0 and 10000 (representing 0% to 100%).
    *
    * @param admin The Ethereum address that has administrative control over the nTreasury
    *              contract. The admin is responsible for managing trustees, adjusting
    *              settings, and overall contract administration.
    *
    * @param requests An array that holds the withdrawal requests created by trustees.
    *                 Each element in the array represents a `Request` struct, containing
    *                 details such as the destination address, token address, withdrawal
    *                 amount, and the status of the request (executed or not).
    *
    * @dev The `isTrustee` mapping allows efficient lookup of trustee status for a given
    * Ethereum address, facilitating quick checks for trustee privileges.
    *
    * @dev The `trusteeCount` is maintained to keep track of the current number of trustees
    * in the contract. It is incremented or decremented when trustee status is added or revoked.
    *
    * @dev The `threshold` parameter defines the minimum percentage of trustee signatures
    * required to execute a withdrawal request. This threshold ensures a secure and distributed
    * multi-signature mechanism, preventing unauthorized withdrawals.
    *
    * @dev The `admin` address has exclusive control over administrative functions, such as
    * managing trustees and adjusting contract settings.
    *
    * @dev The `requests` array stores the details of each withdrawal request initiated by trustees.
    *      The array allows efficient tracking and retrieval of all withdrawal requests within
    *      the nTreasury contract.
    */
    struct StorageTreasury {
        mapping(address => bool) isTrustee;
        uint trusteeCount;
        uint threshold;
        address admin;
        Request[] requests;
    }

    /**
    * @notice Emitted when the status of a trustee is changed.
    *
    * @dev This event is emitted when the admin of the nTreasury contract updates
    * the trustee status of an account, granting or revoking trustee privileges.
    * Trustee privileges enable an account to create and sign withdrawal requests.
    *
    * @param account The address of the account whose trustee status is changed.
    * @param isTrustee A boolean indicating whether the account is granted trustee status (true)
    *                  or if trustee status is revoked (false).
    *
    * @dev The `account` parameter represents the Ethereum address of the account
    * whose trustee status is being modified.
    *
    * @dev The `isTrustee` parameter indicates whether the account is granted trustee
    * privileges (`true`) or if trustee privileges are revoked (`false`).
    *
    * @dev When `isTrustee` is `true`, the account is granted the ability to create
    * and sign withdrawal requests, actively participating in the multi-signature
    * withdrawal process.
    *
    * @dev When `isTrustee` is `false`, the account's trustee privileges are revoked,
    * and the account can no longer create or sign withdrawal requests.
    *
    * @dev This event provides transparency into changes in trustee status, allowing
    * observers to track when new trustees are added or existing trustees are removed
    * by the contract admin.
    *
    * @dev Emits when the `setTreasuryTrustee` function is called by the admin to
    * update trustee status.
    */
    event TreasuryTrusteeChanged(address indexed account, bool indexed isTrustee);

    /**
    * @notice Emitted when a new withdrawal request is created.
    *
    * @dev This event is emitted when a trustee creates a new withdrawal request in
    * the nTreasury contract, initiating the multi-signature withdrawal process.
    *
    * @param sender The Ethereum address of the trustee who initiated the withdrawal request.
    * @param to The destination address specified in the withdrawal request.
    * @param tokenOut The token address specified in the withdrawal request.
    * @param i The index of the newly created withdrawal request.
    *
    * @dev The `sender` parameter represents the Ethereum address of the trustee who
    * initiated the withdrawal request. Only trustees have the privilege to create
    * withdrawal requests, and their address is captured by this parameter.
    *
    * @dev The `to` parameter indicates the destination address to which the funds
    * or tokens will be withdrawn. It represents the recipient of the withdrawal.
    *
    * @dev The `tokenOut` parameter represents the token address (ERC-20) specified
    * in the withdrawal request. If the address is `address(0)`, it indicates a
    * withdrawal of Ether (ETH).
    *
    * @dev The `i` parameter is the index assigned to the newly created withdrawal
    * request. This index can be used to reference and track the specific withdrawal
    * request within the array of requests stored in the nTreasury contract.
    *
    * @dev This event provides transparency into the initiation of withdrawal requests,
    * allowing observers to track when trustees create new requests and specify the
    * destination and token details for each withdrawal.
    *
    * @dev Emits when the `request` function is called by a trustee to create a new
    * withdrawal request.
    */
    event NewTreasuryRequest(address indexed sender, address indexed to, address indexed tokenOut, uint i);

    /**
    * @notice Emitted when a trustee signs a withdrawal request.
    *
    * @dev The `TreasuryRequestSigned` event is emitted when a trustee successfully signs a withdrawal request
    * in the nTreasury contract. Trustees must individually sign withdrawal requests to reach the required
    * threshold for execution, ensuring a secure and distributed multi-signature withdrawal process.
    *
    * @param signer The Ethereum address of the trustee who has signed the withdrawal request.
    *
    * @dev The `signer` parameter represents the Ethereum address of the trustee who has successfully signed
    * the withdrawal request. Each trustee's signature is recorded, allowing the contract to track the progress
    * toward the required threshold for request execution.
    *
    * @dev This event provides transparency into the signing activity of trustees, allowing observers to monitor
    * when each trustee contributes their signature to a withdrawal request. The individual signatures are crucial
    * for reaching the required consensus among trustees and executing the withdrawal securely.
    *
    * @dev Emits when the `sign` function is called by a trustee to sign a withdrawal request.
    */
    event TreasuryRequestSigned(address indexed signer);

    /**
    * @notice Emitted when a withdrawal request is successfully executed.
    *
    * @dev The `TreasuryWithdrawalExecuted` event is emitted when a signed withdrawal request in the
    * nTreasury contract is successfully executed. Execution involves transferring the requested funds
    * or tokens to the specified destination address, marking the completion of the withdrawal process.
    *
    * @param i The index of the executed withdrawal request in the nTreasury contract.
    *
    * @dev The `i` parameter represents the index of the withdrawal request that has been successfully
    * executed. It is an identifier that allows observers to reference and track the specific request
    * within the array of requests stored in the nTreasury contract.
    *
    * @dev This event provides transparency into the execution of withdrawal requests, allowing observers
    * to monitor when a request has been fulfilled and funds or tokens have been transferred as per the
    * trustee's instructions.
    *
    * @dev Emits when the `execute` function is called by a trustee to execute a signed withdrawal request,
    * resulting in the successful transfer of funds or tokens to the specified destination address.
    */
    event TreasuryWithdrawalExecuted(uint indexed i);

    /**
    * @notice Emitted when the admin of the nTreasury contract is changed.
    *
    * @dev The `TreasuryAdminChanged` event is emitted when the admin of the nTreasury contract is updated. The admin is a
    *      privileged role with the authority to appoint and remove trustees, set the withdrawal threshold, and manage other
    *      administrative functions within the contract.
    *
    * @param oldAdmin The Ethereum address of the previous admin before the change.
    * @param newAdmin The Ethereum address of the new admin after the change.
    *
    * @dev The `oldAdmin` parameter represents the Ethereum address of the admin before the change. This provides visibility
    *      into the previous admin, allowing observers to track the transition of administrative authority.
    *
    * @dev The `newAdmin` parameter represents the Ethereum address of the new admin after the change. This indicates the
    *      address that has assumed the admin role, enabling external observers to verify and recognize the updated
    *      administrative authority.
    *
    * @dev This event is crucial for transparency and auditability, as it signals significant changes in the contract's
    *      governance structure. Observers can use this event to monitor changes in admin responsibilities and ensure the
    *      accountability of the nTreasury contract.
    *
    * @dev This event is emitted as part of the access control mechanism, allowing external systems and applications to
    *      react to changes in admin status and adjust their behavior accordingly.
    */
    event TreasuryAdminChanged(address indexed oldAdmin, address indexed newAdmin);

    /**
    * @notice Allows an address to claim the admin role of the nTreasury contract.
    *
    * @dev The `claimTreasury` function enables an address to claim the admin role of the nTreasury contract if the admin
    *      role is currently unassigned (address(0)). Once claimed, the admin gains the authority to appoint and remove
    *      trustees, set the withdrawal threshold, and manage other administrative functions within the contract.
    *
    * @dev If the admin role is already assigned (not equal to address(0)), the function reverts with the error message
    *      'nTreasury: can only be claimed once,' indicating that the admin role can only be claimed once.
    *
    * @dev This function is designed to be called when the nTreasury contract is initially deployed. The first address to
    *      call this function becomes the admin, assuming the responsibility of managing the contract's governance.
    *
    * @dev Emits the `TreasuryAdminChanged` event to signal the change in admin status, from unassigned (address(0)) to the
    *      claiming address. This event provides transparency into the assignment of the admin role and allows external
    *      observers to track the establishment of initial governance.
    *
    * @dev This function is marked as `external` and can be called by any external address. It is expected to be used during
    *      the deployment phase of the contract to establish the initial admin of the nTreasury contract.
    */
    function claimTreasury() external virtual {
        if (_treasury().admin == address(0)) {
            _setTreasuryAdmin(_msgSender());
        } else {
            revert('nTreasury: can only be claimed once');
        }
    }

    /**
    * @notice Sets or revokes trustee status for a specified account.
    *
    * @dev The `setTreasuryTrustee` function allows the admin of the nTreasury contract to update the
    * trustee status of a specified Ethereum address, granting or revoking trustee privileges.
    *
    * @param account The Ethereum address for which trustee status will be updated.
    * @param isTrustee A boolean indicating whether to grant (`true`) or revoke (`false`) trustee status
    *                  for the specified account.
    *
    * @dev The `account` parameter represents the Ethereum address for which trustee status will be modified.
    *
    * @dev The `isTrustee` parameter is a boolean flag. When `true`, it indicates that trustee privileges
    * should be granted to the specified account. When `false`, it signifies that trustee privileges
    * should be revoked for the specified account.
    *
    * @dev Only the admin of the nTreasury contract can call this function, ensuring that only authorized
    * entities have the ability to manage trustee status. This helps maintain the integrity and security
    * of the trustee system within the contract.
    *
    * @dev The function internally calls the `_onlyAdmin` modifier to ensure that only the admin can invoke
    * this privileged operation.
    *
    * @dev The actual logic for setting or revoking trustee status is implemented in the `_setTreasuryTrustee`
    * internal function.
    *
    * @dev Emits the `TreasuryTrusteeChanged` event to signal the change in trustee status for the specified
    * account, providing transparency into the modification of trustee privileges.
    *
    * @dev This function is part of the contract's access control mechanism, allowing the admin to manage and
    * control the list of trustees participating in the multi-signature withdrawal process.
    */
    function setTreasuryTrustee(address account, bool isTrustee) external virtual {
        _onlyAdmin();
        _setTreasuryTrustee(account, isTrustee);
    }

    /**
    * @notice Initiates a new withdrawal request from the nTreasury contract.
    *
    * @dev The `request` function allows a trustee to create a new withdrawal request in the nTreasury contract.
    * Trustees are required to initiate withdrawal requests, specifying details such as the destination address,
    * token to be withdrawn, and the amount to be withdrawn.
    *
    * @param to The destination address to which the funds or tokens will be withdrawn upon successful execution
    *           of the withdrawal request.
    *
    * @param tokenOut The token address (ERC-20) specified in the withdrawal request. If the address is `address(0)`,
    *                 it indicates a withdrawal of Ether (ETH). Otherwise, it represents the specific ERC-20 token
    *                 to be withdrawn.
    *
    * @param amountOut The amount to be withdrawn in the specified token. It represents the quantity of funds or
    *                  tokens requested for withdrawal.
    *
    * @return i The index of the newly created withdrawal request. This index can be used to reference and track the
    *           specific withdrawal request within the array of requests stored in the nTreasury contract.
    *
    * @dev The `to` parameter represents the Ethereum address to which the funds or tokens will be withdrawn upon
    * successful execution of the withdrawal request. It is the recipient of the withdrawal.
    *
    * @dev The `tokenOut` parameter specifies the ERC-20 token to be withdrawn. If the address is `address(0)`, it
    * indicates a withdrawal of Ether (ETH). Otherwise, it represents the specific ERC-20 token.
    *
    * @dev The `amountOut` parameter indicates the quantity of funds or tokens to be withdrawn. It represents the
    * numerical value of the withdrawal amount.
    *
    * @dev The function internally calls the `_onlyTrustee` modifier to ensure that only trustees can initiate
    * withdrawal requests. This access control mechanism prevents unauthorized entities from creating withdrawal
    * requests and contributes to the security of the multi-signature withdrawal process.
    *
    * @dev The actual logic for creating a new withdrawal request is implemented in the `_request` internal function.
    *
    * @dev Emits the `NewTreasuryRequest` event to signal the creation of a new withdrawal request, providing
    * transparency into trustee activity and allowing observers to track the details of each initiated withdrawal.
    *
    * @dev This function is a crucial part of the multi-signature withdrawal process, enabling trustees to propose
    * and initiate withdrawal requests, initiating the consensus-building mechanism.
    */
    function request(address to, address tokenOut, uint amountOut) external virtual returns (uint) {
        _onlyTrustee();
        return _request(to, tokenOut, amountOut);
    }

    /**
    * @notice Allows a trustee to sign a specific withdrawal request.
    *
    * @dev The `sign` function enables a trustee to add their signature to a specified withdrawal request in the
    * nTreasury contract. Trustees must individually sign withdrawal requests, and each signature contributes
    * to reaching the required threshold for execution, ensuring a secure and distributed multi-signature process.
    *
    * @param i The index of the withdrawal request to be signed.
    *
    * @dev The `i` parameter represents the index of the withdrawal request that the trustee intends to sign.
    * It is an identifier that allows the contract to locate and track the specific request within the array of
    * requests stored in the nTreasury contract.
    *
    * @dev The function internally calls the `_onlyTrustee` modifier to ensure that only trustees can add their
    * signatures to withdrawal requests. This access control mechanism prevents unauthorized entities from signing
    * requests and contributes to the security of the multi-signature withdrawal process.
    *
    * @dev The function further calls the `_onlyNotSigned` modifier to ensure that the trustee has not already
    * signed the specified withdrawal request. This check prevents duplicate signatures and ensures that each
    * trustee signs a request only once.
    *
    * @dev The actual logic for adding the trustee's signature is implemented in the `_sign` internal function.
    *
    * @dev Emits the `TreasuryRequestSigned` event to signal the successful addition of the trustee's signature
    * to the withdrawal request. This event provides transparency into the signing activity of trustees and allows
    * observers to track the progress toward the required threshold for request execution.
    *
    * @dev This function is a critical step in the multi-signature withdrawal process, where trustees individually
    * sign requests to achieve consensus and trigger the execution of the withdrawal.
    */
    function sign(uint i) external virtual {
        _onlyTrustee();
        _onlyNotSigned(i);
        _sign(i);
    }

    /**
    * @notice Executes a signed and non-executed withdrawal request in the nTreasury contract.
    *
    * @dev The `execute` external function allows a trustee to execute a previously signed and non-executed withdrawal
    *      request in the nTreasury contract. Execution involves transferring the requested funds or tokens to the
    *      specified destination address, marking the completion of the withdrawal process.
    *
    * @param i The index of the signed and non-executed withdrawal request to be executed.
    *
    * @dev The `i` parameter represents the index of the withdrawal request that the trustee intends to execute. It is an
    *      identifier that allows the contract to locate and track the specific request within the array of requests stored
    *      in the nTreasury contract.
    *
    * @dev The function first checks whether the specified withdrawal request has not been executed. If the request has
    *      already been executed, the function reverts with the error message 'nTreasury: request already executed.'
    *
    * @dev The function then checks whether the caller is a trustee. If the caller is not a trustee, the function reverts
    *      with the error message 'nTreasury: only trustee,' ensuring that only authorized trustees can execute withdrawal
    *      requests.
    *
    * @dev If both checks pass, the function calls the internal `_execute` function to perform the execution of the withdrawal
    *      request. The `_execute` function handles the validation of the signature threshold and the actual transfer of
    *      funds or tokens.
    *
    * @dev This function is a crucial step in the multi-signature withdrawal process, where trustees collaboratively sign and
    *      execute requests to securely withdraw funds or tokens from the nTreasury contract. The additional check ensures that
    *      a request cannot be executed more than once, preventing unintended or malicious double executions.
    *
    * @dev This function is meant to be called by trustees externally, providing a user-friendly interface for executing
    *      signed withdrawal requests.
    */
    function execute(uint i) external virtual {
        _onlyNotExecuted(i);
        _onlyTrustee();
        _execute(i);
    }

    /**
    * @notice Retrieves the storage structure for the nTreasury contract.
    *
    * @dev The `_treasury` internal function is responsible for returning a reference to the storage structure
    * associated with the nTreasury contract. This structure, defined by the `StorageTreasury` struct, contains
    * critical information such as trustee status, administrative control, withdrawal requests, and other essential
    * data required for the functionality of the nTreasury contract.
    *
    * @return s A reference to the storage structure (`StorageTreasury`) of the nTreasury contract.
    *
    * @dev The function uses assembly to dynamically retrieve the storage slot associated with the nTreasury contract
    * using the `_TREASURY` constant. This ensures a more efficient and gas-friendly way to access the contract's storage.
    *
    * @dev The returned `s` reference allows other functions within the contract to directly interact with and modify
    * the nTreasury contract's storage. This internal function encapsulates the storage access logic, providing a
    * convenient and centralized way to access the contract's storage from other internal functions.
    *
    * @dev Note: The `pure` modifier is used to indicate that this function does not modify the state of the contract.
    * Despite the assembly usage, the function is marked as `pure` because it only reads from storage and does not alter
    * the contract's state.
    *
    * @dev This function is internal and should not be called directly by external contracts or users. Its purpose is to
    * provide a clean and centralized way for other internal functions to access the nTreasury contract's storage structure.
    */
    function _treasury() internal pure virtual returns (StorageTreasury storage s) {
        bytes32 location = _TREASURY;
        assembly {
            s.slot := location
        }
    }

    /**
    * @notice Ensures that the caller is the admin of the nTreasury contract.
    *
    * @dev The `_onlyAdmin` internal function is a modifier-like function that ensures that the Ethereum address
    * calling the function is the designated admin of the nTreasury contract. Only the admin has the privilege
    * to perform certain administrative actions, such as managing trustees, adjusting settings, and overall
    * contract administration.
    *
    * @dev If the caller is not the admin, the function will revert with the error message 'nTreasury: only admin.'
    *
    * @dev This function is used as a modifier in other functions to restrict access to privileged operations
    * to the admin only. It contributes to the access control mechanism of the nTreasury contract, ensuring
    * that only authorized entities can perform administrative functions.
    *
    * @dev The function relies on the `_treasury` internal function to retrieve the storage structure of the
    * nTreasury contract, allowing it to access the admin address stored in the contract's storage.
    *
    * @dev This function is marked as `view` because it only reads from the contract's state and does not modify it.
    *
    * @dev This function is internal and should not be called directly by external contracts or users. It is meant
    * to be used as a modifier to enforce access control in functions that require admin privileges.
    */
    function _onlyAdmin() internal view virtual {
        require(_msgSender() == _treasury().admin, 'nTreasury: only admin');
    }

    /**
    * @notice Ensures that the caller is a trustee in the nTreasury contract.
    *
    * @dev The `_onlyTrustee` internal function is a modifier-like function that ensures that the Ethereum address
    * calling the function is a trustee in the nTreasury contract. Trustees are entities with special privileges
    * to initiate withdrawal requests, sign requests, and participate in the multi-signature withdrawal process.
    *
    * @dev If the caller is not a trustee, the function will revert with the error message 'nTreasury: only trustee.'
    *
    * @dev This function is used as a modifier in other functions to restrict access to trustee-specific operations
    * to addresses that have been granted trustee privileges. It contributes to the access control mechanism of the
    * nTreasury contract, ensuring that only authorized trustees can perform trustee-related functions.
    *
    * @dev The function relies on the `_treasury` internal function to retrieve the storage structure of the nTreasury
    * contract, allowing it to check the trustee status of the caller's address stored in the contract's storage.
    *
    * @dev This function is marked as `view` because it only reads from the contract's state and does not modify it.
    *
    * @dev This function is internal and should not be called directly by external contracts or users. It is meant
    * to be used as a modifier to enforce access control in functions that require trustee privileges.
    */
    function _onlyTrustee() internal view virtual {
        require(_treasury().isTrustee[_msgSender()], 'nTreasury: only trustee');
    }

    /**
    * @notice Ensures that the caller has not already signed a specific withdrawal request.
    *
    * @dev The `_onlyNotSigned` internal function is a modifier-like function that ensures that the Ethereum address
    * calling the function has not already signed a specific withdrawal request in the nTreasury contract. This check
    * is crucial to prevent duplicate signatures on the same request and ensures that each trustee signs a request only once.
    *
    * @param i The index of the withdrawal request being checked for existing signatures.
    *
    * @dev The `i` parameter represents the index of the withdrawal request for which the function checks whether the
    * caller has already signed. It is an identifier that allows the contract to locate and track the specific request
    * within the array of requests stored in the nTreasury contract.
    *
    * @dev If the caller has already signed the specified withdrawal request, the function will revert with the error
    * message 'nTreasury: already signed.'
    *
    * @dev This function is used as a modifier in other functions to enforce the rule that trustees should only sign a
    * specific withdrawal request once. It contributes to the integrity of the multi-signature withdrawal process and
    * ensures that each trustee's signature is unique for a given request.
    *
    * @dev The function relies on the `_treasury` internal function to retrieve the storage structure of the nTreasury
    * contract and access the `hasSigned` mapping for the specified withdrawal request.
    *
    * @dev This function is marked as `view` because it only reads from the contract's state and does not modify it.
    *
    * @dev This function is internal and should not be called directly by external contracts or users. It is meant to
    * be used as a modifier to enforce access control in functions that require unique trustee signatures.
    */
    function _onlyNotSigned(uint i) internal view virtual {
        require(!_treasury().requests[i].hasSigned[_msgSender()], 'nTreasury: already signed');
    }

    /**
    * @notice Ensures that a specified withdrawal request has not been executed.
    *
    * @dev The `_onlyNotExecuted` internal function is a modifier that ensures a specified withdrawal request has not
    *      been executed before proceeding with further actions. This prevents unintended or malicious double executions
    *      of the same withdrawal request.
    *
    * @param i The index of the withdrawal request to check for execution status.
    *
    * @dev The `i` parameter represents the index of the withdrawal request that is being checked. It is an identifier
    *      that allows the contract to locate and track the specific request within the array of requests stored in the
    *      nTreasury contract.
    *
    * @dev The function checks the `executed` flag in the specified withdrawal request. If the flag is true (indicating
    *      that the request has already been executed), the function reverts with the error message 'nTreasury: already executed.'
    *
    * @dev This internal function is used as a modifier in other functions, ensuring that only non-executed withdrawal
    *      requests can proceed with additional actions, such as signing or execution. It enhances the security and integrity
    *      of the multi-signature withdrawal process by preventing duplicate executions of the same request.
    *
    * @dev This function is marked as `internal` and should not be called directly by external contracts or users. It is meant
    *      to be used internally within the nTreasury contract to enforce the non-executed condition for specific withdrawal requests.
    */
    function _onlyNotExecuted(uint i) internal view virtual {
        require(!_treasury().requests[i].executed, 'nTreasury: already executed');
    }

    /**
    * @notice Sets a new admin for the nTreasury contract.
    *
    * @dev The `_setTreasuryAdmin` internal function is responsible for setting a new admin for the nTreasury contract. It
    *      updates the admin address in the contract's storage, signaling a change in administrative authority.
    *
    * @param account The Ethereum address to be set as the new admin for the nTreasury contract.
    *
    * @dev The `account` parameter represents the Ethereum address to be assigned as the new admin. This address assumes
    *      the responsibility of managing the contract's governance, including appointing and removing trustees, setting
    *      the withdrawal threshold, and other administrative functions.
    *
    * @dev The function retrieves the current admin address (`oldAdmin`) from the contract's storage, then updates the
    *      admin to the new address (`account`). It emits the `TreasuryAdminChanged` event to signal the change in admin
    *      status, providing transparency into the transition of administrative authority.
    *
    * @dev This function is designed to be used internally within the nTreasury contract, typically in scenarios where a
    *      new admin is assigned, such as during the claiming process in the `claimTreasury` function.
    *
    * @dev This function is marked as `internal` and should not be called directly by external contracts or users. It is
    *      meant to be used internally within the nTreasury contract to manage changes in admin status.
    */
    function _setTreasuryAdmin(address account) internal virtual {
        address oldAdmin = _treasury().admin;
        _treasury().admin = account;
        emit TreasuryAdminChanged(oldAdmin, newAdmin);
    }

    /**
    * @notice Updates the trustee status for a specified account in the nTreasury contract.
    *
    * @dev The `_setTreasuryTrustee` internal function is responsible for updating the trustee status of a specified
    * Ethereum address in the nTreasury contract. This function is used internally to grant or revoke trustee privileges.
    *
    * @param account The Ethereum address for which trustee status will be updated.
    * @param isTrustee A boolean indicating whether to grant (`true`) or revoke (`false`) trustee status for the specified account.
    *
    * @dev The `account` parameter represents the Ethereum address for which trustee status will be modified.
    *
    * @dev The `isTrustee` parameter is a boolean flag. When `true`, it indicates that trustee privileges should be granted
    * to the specified account. When `false`, it signifies that trustee privileges should be revoked for the specified account.
    *
    * @dev The function updates the `isTrustee` mapping in the nTreasury contract's storage, indicating the trustee status
    * of the specified account. Additionally, it adjusts the `trusteeCount` to reflect the total number of trustees in the contract.
    *
    * @dev If trustee privileges are granted (`isTrustee` is `true`), the `trusteeCount` is incremented. If trustee privileges
    * are revoked (`isTrustee` is `false`), the `trusteeCount` is decremented.
    *
    * @dev The function emits the `TreasuryTrusteeChanged` event to signal the change in trustee status for the specified account.
    * This event provides transparency into trustee-related actions and allows observers to track changes in trustee privileges.
    *
    * @dev This function is marked as `internal` and should not be called directly by external contracts or users. It is meant to
    * be used internally within the nTreasury contract to manage trustee status.
    */
    function _setTreasuryTrustee(address account, bool isTrustee) internal virtual {
        _treasury().isTrustee[account] = isTrustee;
        if (isTrustee) {
            _treasury().trusteeCount += 1;
        } else {
            _treasury().trusteeCount -= 1;
        }
        emit TreasuryTrusteeChanged(account, isTrustee);
    }

    /**
    * @notice Initiates a new withdrawal request within the nTreasury contract.
    *
    * @dev The `_request` internal function is responsible for creating a new withdrawal request within the nTreasury contract.
    * This function is intended to be called by trustees to propose withdrawal requests, specifying the destination address,
    * token to be withdrawn, and the amount to be withdrawn.
    *
    * @param to The destination address to which the funds or tokens will be withdrawn upon successful execution
    *           of the withdrawal request.
    *
    * @param tokenOut The token address (ERC-20) specified in the withdrawal request. If the address is `address(0)`,
    *                 it indicates a withdrawal of Ether (ETH). Otherwise, it represents the specific ERC-20 token
    *                 to be withdrawn.
    *
    * @param amountOut The amount to be withdrawn in the specified token. It represents the quantity of funds or
    *                  tokens requested for withdrawal.
    *
    * @return i The index of the newly created withdrawal request. This index can be used to reference and track the
    *           specific withdrawal request within the array of requests stored in the nTreasury contract.
    *
    * @dev The `to` parameter represents the Ethereum address to which the funds or tokens will be withdrawn upon
    * successful execution of the withdrawal request. It is the recipient of the withdrawal.
    *
    * @dev The `tokenOut` parameter specifies the ERC-20 token to be withdrawn. If the address is `address(0)`, it
    * indicates a withdrawal of Ether (ETH). Otherwise, it represents the specific ERC-20 token.
    *
    * @dev The `amountOut` parameter indicates the quantity of funds or tokens to be withdrawn. It represents the
    * numerical value of the withdrawal amount.
    *
    * @dev The function appends a new `Request` struct to the `requests` array in the nTreasury contract's storage,
    * representing the details of the withdrawal request. The `numSignatures` and `executed` fields are initialized,
    * and the function returns the index of the newly created request.
    *
    * @dev Emits the `NewTreasuryRequest` event to signal the creation of a new withdrawal request, providing
    * transparency into trustee activity and allowing observers to track the details of each initiated withdrawal.
    *
    * @dev This function is marked as `internal` and should not be called directly by external contracts or users.
    * It is meant to be used internally within the nTreasury contract to facilitate the creation of withdrawal requests.
    */
    function _request(address to, address tokenOut, uint amountOut) internal virtual returns (uint) {
        _treasury().requests.push(Request(to, tokenOut, amountOut, 0, false));
        uint i = _treasury().requests.length - 1;
        emit NewTreasuryRequest(_msgSender(), to, tokenOut, i);
        return i;
    }

    /**
    * @notice Adds the caller's signature to a specific withdrawal request.
    *
    * @dev The `_sign` internal function allows a trustee to add their signature to a specified withdrawal request in the
    * nTreasury contract. Trustees must individually sign withdrawal requests, and each signature contributes to reaching
    * the required threshold for execution, ensuring a secure and distributed multi-signature process.
    *
    * @param i The index of the withdrawal request to be signed.
    *
    * @dev The `i` parameter represents the index of the withdrawal request that the trustee intends to sign. It is an
    * identifier that allows the contract to locate and track the specific request within the array of requests stored
    * in the nTreasury contract.
    *
    * @dev The function updates the `hasSigned` mapping of the specified withdrawal request, marking the caller's address
    * as having signed the request.
    *
    * @dev Emits the `TreasuryRequestSigned` event to signal the successful addition of the trustee's signature to the
    * withdrawal request. This event provides transparency into the signing activity of trustees and allows observers
    * to track the progress toward the required threshold for request execution.
    *
    * @dev This function is marked as `internal` and should not be called directly by external contracts or users. It is
    * meant to be used internally within the nTreasury contract to facilitate the signing of withdrawal requests by trustees.
    */
    function _sign(uint i) internal virtual {
        _treasury().requests[i].hasSigned[_msgSender()] = true;
        emit TreasuryRequestSigned(_msgSender());
    }

    /**
    * @notice Executes a signed withdrawal request in the nTreasury contract.
    *
    * @dev The `_execute` internal function allows a trustee to execute a previously signed withdrawal request in the
    *      nTreasury contract. Execution involves transferring the requested funds or tokens to the specified destination
    *      address, marking the completion of the withdrawal process.
    *
    * @param i The index of the signed withdrawal request to be executed.
    *
    * @dev The `i` parameter represents the index of the withdrawal request that the trustee intends to execute. It is an
    *      identifier that allows the contract to locate and track the specific request within the array of requests stored
    *      in the nTreasury contract.
    *
    * @dev The function first retrieves information about the specified withdrawal request, including the destination
    *      address (`to`), the ERC-20 token address (`tokenOut`), the amount to be transferred (`amountOut`), and the
    *      number of signatures obtained (`numSignatures`).
    *
    * @dev The function calculates the current signature threshold based on the number of signatures obtained compared to the
    *      total number of trustees. If the current threshold is equal to or exceeds the required threshold, the function
    *      proceeds with the execution of the withdrawal request.
    *
    * @dev The function then marks the request as executed, preventing further executions of the same request. If the request
    *      involves a specific ERC-20 token (`tokenOut` is not `address(0)`), the function calls the `_transferTokens`
    *      internal function to transfer the requested amount of tokens to the specified destination address. Otherwise, if
    *      the request involves Ether withdrawal, the function calls the `_transfer` internal function to transfer the
    *      requested amount of Ether.
    *
    * @dev The function emits the `TreasuryWithdrawalExecuted` event to signal the successful execution of the withdrawal
    *      request. This event provides transparency into the completion of the withdrawal process, allowing observers to
    *      monitor when a request has been fulfilled and funds or tokens have been transferred as per the trustee's instructions.
    *
    * @dev This function is a crucial step in the multi-signature withdrawal process, where trustees collaboratively sign and
    *      execute requests to securely withdraw funds or tokens from the nTreasury contract.
    *
    * @dev This function is marked as `internal` and should not be called directly by external contracts or users. It is meant
    *      to be used internally within the nTreasury contract to facilitate the execution of signed withdrawal requests.
    */
    function _execute(uint i) internal virtual {
        Request storage request = _treasury().requests[i];
        uint trusteeCount = _treasury().trusteeCount;
        uint threshold = _treasury().threshold;
        uint currThreshold = (request.numSignatures * 10000) / trusteeCount;
        require(currThreshold >= threshold, 'nTreasury: insufficient signatures');
        _treasury().requests[i].executed = true;
        if (request.tokenOut != address(0)) {
            _transferTokens(request.to, request.tokenOut, request.amountOut);
        } else {
            _transfer(request.to, request.amountOut);
        }
        emit TreasuryWithdrawalExecuted(i);
    }

    /**
    * @notice Transfers Ether to a specified destination address.
    *
    * @dev The `_transfer` internal function facilitates the transfer of Ether from the nTreasury contract to a specified
    * destination address. This function is typically called during the execution of a withdrawal request involving Ether.
    *
    * @param to The destination address to which the Ether will be transferred.
    * @param amountOut The amount of Ether to be transferred.
    *
    * @dev The `to` parameter represents the Ethereum address to which the Ether will be transferred upon successful execution
    * of the withdrawal request. It is the recipient of the Ether transfer.
    *
    * @dev The `amountOut` parameter indicates the quantity of Ether to be transferred. It represents the numerical value of
    * the Ether transfer amount.
    *
    * @dev The function checks whether the nTreasury contract's current balance is sufficient to cover the requested Ether
    * transfer. If the balance is insufficient, the function reverts with the error message 'nTreasury: insufficient balance.'
    *
    * @dev The function uses the `payable` modifier to enable the transfer of Ether to the specified destination address.
    * The transfer is executed using the `.transfer` method, which ensures that only the specified amount of Ether is
    * transferred, preventing reentrancy attacks.
    *
    * @dev This function is an essential component of the multi-signature withdrawal process in the nTreasury contract,
    * where trustees collaboratively sign and execute requests to securely withdraw funds from the contract.
    *
    * @dev This function is marked as `internal` and should not be called directly by external contracts or users. It is
    * meant to be used internally within the nTreasury contract to facilitate the transfer of Ether during request execution.
    */
    function _transfer(address to, uint amountOut) internal virtual {
        require(address(this).balance >= amountOut, 'nTreasury: insufficient balance');
        payable(to).transfer(amountOut);
    }

    /**
    * @notice Transfers ERC-20 tokens to a specified destination address.
    *
    * @dev The `_transferTokens` internal function facilitates the transfer of ERC-20 tokens from the nTreasury contract
    * to a specified destination address. This function is typically called during the execution of a withdrawal request
    * involving ERC-20 tokens.
    *
    * @param to The destination address to which the ERC-20 tokens will be transferred.
    * @param tokenOut The token address (ERC-20) specified in the withdrawal request.
    * @param amountOut The amount of ERC-20 tokens to be transferred.
    *
    * @dev The `to` parameter represents the Ethereum address to which the ERC-20 tokens will be transferred upon successful
    * execution of the withdrawal request. It is the recipient of the ERC-20 token transfer.
    *
    * @dev The `tokenOut` parameter specifies the ERC-20 token to be transferred. It represents the specific ERC-20 token
    * involved in the withdrawal request.
    *
    * @dev The `amountOut` parameter indicates the quantity of ERC-20 tokens to be transferred. It represents the numerical
    * value of the ERC-20 token transfer amount.
    *
    * @dev The function checks whether the nTreasury contract's current balance of the specified ERC-20 token is sufficient
    * to cover the requested token transfer. If the balance is insufficient, the function reverts with the error message
    * 'nTreasury: insufficient balance.'
    *
    * @dev The function uses the `IERC20Metadata` interface to interact with the ERC-20 token contract and calls the
    * `transfer` method to initiate the token transfer. This ensures that only the specified amount of ERC-20 tokens is
    * transferred to the destination address.
    *
    * @dev This function is an essential component of the multi-signature withdrawal process in the nTreasury contract,
    * where trustees collaboratively sign and execute requests to securely withdraw funds in the form of ERC-20 tokens.
    *
    * @dev This function is marked as `internal` and should not be called directly by external contracts or users. It is
    * meant to be used internally within the nTreasury contract to facilitate the transfer of ERC-20 tokens during request execution.
    */
    function _transferTokens(address to, address tokenOut, uint amountOut) internal virtual {
        require(IERC20Metadata(tokenOut).balanceOf(address(this)) >= amountOut, 'nTreasury: insufficient balance');
        IERC20Metadata(tokenOut).transfer(to, amountOut);
    }
}