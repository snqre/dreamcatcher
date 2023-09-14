namespace Dreamcatcher.Contracts.IState

open System
open System.Threading.Tasks
open System.Collections.Generic
open System.Numerics
open Nethereum.Hex.HexTypes
open Nethereum.ABI.FunctionEncoding.Attributes
open Nethereum.Web3
open Nethereum.RPC.Eth.DTOs
open Nethereum.Contracts.CQS
open Nethereum.Contracts.ContractHandlers
open Nethereum.Contracts
open System.Threading
open Dreamcatcher.Contracts.IState.ContractDefinition


    type IStateService (web3: Web3, contractAddress: string) =
    
        member val Web3 = web3 with get
        member val ContractHandler = web3.Eth.GetContractHandler(contractAddress) with get
    
        static member DeployContractAndWaitForReceiptAsync(web3: Web3, iStateDeployment: IStateDeployment, ?cancellationTokenSource : CancellationTokenSource): Task<TransactionReceipt> = 
            let cancellationTokenSourceVal = defaultArg cancellationTokenSource null
            web3.Eth.GetContractDeploymentHandler<IStateDeployment>().SendRequestAndWaitForReceiptAsync(iStateDeployment, cancellationTokenSourceVal)
        
        static member DeployContractAsync(web3: Web3, iStateDeployment: IStateDeployment): Task<string> =
            web3.Eth.GetContractDeploymentHandler<IStateDeployment>().SendRequestAsync(iStateDeployment)
        
        static member DeployContractAndGetServiceAsync(web3: Web3, iStateDeployment: IStateDeployment, ?cancellationTokenSource : CancellationTokenSource) = async {
            let cancellationTokenSourceVal = defaultArg cancellationTokenSource null
            let! receipt = IStateService.DeployContractAndWaitForReceiptAsync(web3, iStateDeployment, cancellationTokenSourceVal) |> Async.AwaitTask
            return new IStateService(web3, receipt.ContractAddress);
            }
    
        member this.AccessQueryAsync(accessFunction: AccessFunction, ?blockParameter: BlockParameter): Task<byte[]> =
            let blockParameterVal = defaultArg blockParameter null
            this.ContractHandler.QueryAsync<AccessFunction, byte[]>(accessFunction, blockParameterVal)
            
        member this.CoreQueryAsync(coreFunction: CoreFunction, ?blockParameter: BlockParameter): Task<bool> =
            let blockParameterVal = defaultArg blockParameter null
            this.ContractHandler.QueryAsync<CoreFunction, bool>(coreFunction, blockParameterVal)
            
        member this.EmptyQueryAsync(emptyFunction: EmptyFunction, ?blockParameter: BlockParameter): Task<bool> =
            let blockParameterVal = defaultArg blockParameter null
            this.ContractHandler.QueryAsync<EmptyFunction, bool>(emptyFunction, blockParameterVal)
            
        member this.LatestQueryAsync(latestFunction: LatestFunction, ?blockParameter: BlockParameter): Task<string> =
            let blockParameterVal = defaultArg blockParameter null
            this.ContractHandler.QueryAsync<LatestFunction, string>(latestFunction, blockParameterVal)
            
        member this.LockRequestAsync(@lockFunction: LockFunction): Task<string> =
            this.ContractHandler.SendRequestAsync(@lockFunction);
        
        member this.LockRequestAndWaitForReceiptAsync(@lockFunction: LockFunction, ?cancellationTokenSource : CancellationTokenSource): Task<TransactionReceipt> =
            let cancellationTokenSourceVal = defaultArg cancellationTokenSource null
            this.ContractHandler.SendRequestAndWaitForReceiptAsync(@lockFunction, cancellationTokenSourceVal);
        
        member this.LockedQueryAsync(lockedFunction: LockedFunction, ?blockParameter: BlockParameter): Task<bool> =
            let blockParameterVal = defaultArg blockParameter null
            this.ContractHandler.QueryAsync<LockedFunction, bool>(lockedFunction, blockParameterVal)
            
        member this.ModuleQueryAsync(moduleFunction: ModuleFunction, ?blockParameter: BlockParameter): Task<string> =
            let blockParameterVal = defaultArg blockParameter null
            this.ContractHandler.QueryAsync<ModuleFunction, string>(moduleFunction, blockParameterVal)
            
        member this.PauseRequestAsync(pauseFunction: PauseFunction): Task<string> =
            this.ContractHandler.SendRequestAsync(pauseFunction);
        
        member this.PauseRequestAndWaitForReceiptAsync(pauseFunction: PauseFunction, ?cancellationTokenSource : CancellationTokenSource): Task<TransactionReceipt> =
            let cancellationTokenSourceVal = defaultArg cancellationTokenSource null
            this.ContractHandler.SendRequestAndWaitForReceiptAsync(pauseFunction, cancellationTokenSourceVal);
        
        member this.PreviousQueryAsync(previousFunction: PreviousFunction, ?blockParameter: BlockParameter): Task<string> =
            let blockParameterVal = defaultArg blockParameter null
            this.ContractHandler.QueryAsync<PreviousFunction, string>(previousFunction, blockParameterVal)
            
        member this.StoreRequestAsync(storeFunction: StoreFunction): Task<string> =
            this.ContractHandler.SendRequestAsync(storeFunction);
        
        member this.StoreRequestAndWaitForReceiptAsync(storeFunction: StoreFunction, ?cancellationTokenSource : CancellationTokenSource): Task<TransactionReceipt> =
            let cancellationTokenSourceVal = defaultArg cancellationTokenSource null
            this.ContractHandler.SendRequestAndWaitForReceiptAsync(storeFunction, cancellationTokenSourceVal);
        
        member this.TimerRequestAsync(timerFunction: TimerFunction): Task<string> =
            this.ContractHandler.SendRequestAsync(timerFunction);
        
        member this.TimerRequestAndWaitForReceiptAsync(timerFunction: TimerFunction, ?cancellationTokenSource : CancellationTokenSource): Task<TransactionReceipt> =
            let cancellationTokenSourceVal = defaultArg cancellationTokenSource null
            this.ContractHandler.SendRequestAndWaitForReceiptAsync(timerFunction, cancellationTokenSourceVal);
        
        member this.TimerSetQueryAsync(timerSetFunction: TimerSetFunction, ?blockParameter: BlockParameter): Task<bool> =
            let blockParameterVal = defaultArg blockParameter null
            this.ContractHandler.QueryAsync<TimerSetFunction, bool>(timerSetFunction, blockParameterVal)
            
        member this.TimestampQueryAsync(timestampFunction: TimestampFunction, ?blockParameter: BlockParameter): Task<ulong> =
            let blockParameterVal = defaultArg blockParameter null
            this.ContractHandler.QueryAsync<TimestampFunction, ulong>(timestampFunction, blockParameterVal)
            
        member this.UnpauseRequestAsync(unpauseFunction: UnpauseFunction): Task<string> =
            this.ContractHandler.SendRequestAsync(unpauseFunction);
        
        member this.UnpauseRequestAndWaitForReceiptAsync(unpauseFunction: UnpauseFunction, ?cancellationTokenSource : CancellationTokenSource): Task<TransactionReceipt> =
            let cancellationTokenSourceVal = defaultArg cancellationTokenSource null
            this.ContractHandler.SendRequestAndWaitForReceiptAsync(unpauseFunction, cancellationTokenSourceVal);
        
        member this.UpdateRequestAsync(updateFunction: UpdateFunction): Task<string> =
            this.ContractHandler.SendRequestAsync(updateFunction);
        
        member this.UpdateRequestAndWaitForReceiptAsync(updateFunction: UpdateFunction, ?cancellationTokenSource : CancellationTokenSource): Task<TransactionReceipt> =
            let cancellationTokenSourceVal = defaultArg cancellationTokenSource null
            this.ContractHandler.SendRequestAndWaitForReceiptAsync(updateFunction, cancellationTokenSourceVal);
        
        member this.UpgradeRequestAsync(upgradeFunction: UpgradeFunction): Task<string> =
            this.ContractHandler.SendRequestAsync(upgradeFunction);
        
        member this.UpgradeRequestAndWaitForReceiptAsync(upgradeFunction: UpgradeFunction, ?cancellationTokenSource : CancellationTokenSource): Task<TransactionReceipt> =
            let cancellationTokenSourceVal = defaultArg cancellationTokenSource null
            this.ContractHandler.SendRequestAndWaitForReceiptAsync(upgradeFunction, cancellationTokenSourceVal);
        
        member this.VersionQueryAsync(versionFunction: VersionFunction, ?blockParameter: BlockParameter): Task<BigInteger> =
            let blockParameterVal = defaultArg blockParameter null
            this.ContractHandler.QueryAsync<VersionFunction, BigInteger>(versionFunction, blockParameterVal)
            
        member this.WipeRequestAsync(wipeFunction: WipeFunction): Task<string> =
            this.ContractHandler.SendRequestAsync(wipeFunction);
        
        member this.WipeRequestAndWaitForReceiptAsync(wipeFunction: WipeFunction, ?cancellationTokenSource : CancellationTokenSource): Task<TransactionReceipt> =
            let cancellationTokenSourceVal = defaultArg cancellationTokenSource null
            this.ContractHandler.SendRequestAndWaitForReceiptAsync(wipeFunction, cancellationTokenSourceVal);
        
    

