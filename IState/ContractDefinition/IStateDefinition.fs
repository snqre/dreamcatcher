namespace Dreamcatcher.Contracts.IState.ContractDefinition

open System
open System.Threading.Tasks
open System.Collections.Generic
open System.Numerics
open Nethereum.Hex.HexTypes
open Nethereum.ABI.FunctionEncoding.Attributes
open Nethereum.RPC.Eth.DTOs
open Nethereum.Contracts.CQS
open Nethereum.Contracts
open System.Threading

    
    
    type IStateDeployment(byteCode: string) =
        inherit ContractDeploymentMessage(byteCode)
        
        static let BYTECODE = ""
        
        new() = IStateDeployment(BYTECODE)
        

        
    
    [<Function("access", "bytes")>]
    type AccessFunction() = 
        inherit FunctionMessage()
    
            [<Parameter("bytes32", "location", 1)>]
            member val public Location = Unchecked.defaultof<byte[]> with get, set
        
    
    [<Function("core", "bool")>]
    type CoreFunction() = 
        inherit FunctionMessage()
    

        
    
    [<Function("empty", "bool")>]
    type EmptyFunction() = 
        inherit FunctionMessage()
    
            [<Parameter("bytes32", "location", 1)>]
            member val public Location = Unchecked.defaultof<byte[]> with get, set
        
    
    [<Function("latest", "address")>]
    type LatestFunction() = 
        inherit FunctionMessage()
    

        
    
    [<Function("lock")>]
    type LockFunction() = 
        inherit FunctionMessage()
    

        
    
    [<Function("locked", "bool")>]
    type LockedFunction() = 
        inherit FunctionMessage()
    

        
    
    [<Function("module", "string")>]
    type ModuleFunction() = 
        inherit FunctionMessage()
    

        
    
    [<Function("pause")>]
    type PauseFunction() = 
        inherit FunctionMessage()
    

        
    
    [<Function("previous", "address")>]
    type PreviousFunction() = 
        inherit FunctionMessage()
    
            [<Parameter("uint256", "index", 1)>]
            member val public Index = Unchecked.defaultof<BigInteger> with get, set
        
    
    [<Function("store")>]
    type StoreFunction() = 
        inherit FunctionMessage()
    
            [<Parameter("bytes32", "location", 1)>]
            member val public Location = Unchecked.defaultof<byte[]> with get, set
            [<Parameter("bytes", "data", 2)>]
            member val public Data = Unchecked.defaultof<byte[]> with get, set
        
    
    [<Function("timer")>]
    type TimerFunction() = 
        inherit FunctionMessage()
    
            [<Parameter("uint64", "duration", 1)>]
            member val public Duration = Unchecked.defaultof<ulong> with get, set
        
    
    [<Function("timerSet", "bool")>]
    type TimerSetFunction() = 
        inherit FunctionMessage()
    

        
    
    [<Function("timestamp", "uint64")>]
    type TimestampFunction() = 
        inherit FunctionMessage()
    

        
    
    [<Function("unpause")>]
    type UnpauseFunction() = 
        inherit FunctionMessage()
    

        
    
    [<Function("update")>]
    type UpdateFunction() = 
        inherit FunctionMessage()
    
            [<Parameter("string", "nameModule", 1)>]
            member val public NameModule = Unchecked.defaultof<string> with get, set
        
    
    [<Function("upgrade")>]
    type UpgradeFunction() = 
        inherit FunctionMessage()
    
            [<Parameter("address", "newLogic", 1)>]
            member val public NewLogic = Unchecked.defaultof<string> with get, set
        
    
    [<Function("version", "uint256")>]
    type VersionFunction() = 
        inherit FunctionMessage()
    

        
    
    [<Function("wipe")>]
    type WipeFunction() = 
        inherit FunctionMessage()
    

        
    
    [<Event("Locked")>]
    type LockedEventDTO() =
        inherit EventDTO()
            [<Parameter("address", "msgSender", 1, true )>]
            member val MsgSender = Unchecked.defaultof<string> with get, set
        
    
    [<Event("Stored")>]
    type StoredEventDTO() =
        inherit EventDTO()
            [<Parameter("address", "msgSender", 1, true )>]
            member val MsgSender = Unchecked.defaultof<string> with get, set
            [<Parameter("bytes32", "location", 2, true )>]
            member val Location = Unchecked.defaultof<byte[]> with get, set
            [<Parameter("bytes", "data", 3, true )>]
            member val Data = Unchecked.defaultof<byte[]> with get, set
        
    
    [<Event("TimerSet")>]
    type TimerSetEventDTO() =
        inherit EventDTO()
            [<Parameter("address", "msgSender", 1, true )>]
            member val MsgSender = Unchecked.defaultof<string> with get, set
            [<Parameter("uint64", "duration", 2, true )>]
            member val Duration = Unchecked.defaultof<ulong> with get, set
        
    
    [<Event("Updated")>]
    type UpdatedEventDTO() =
        inherit EventDTO()
            [<Parameter("address", "msgSender", 1, true )>]
            member val MsgSender = Unchecked.defaultof<string> with get, set
            [<Parameter("string", "module", 2, true )>]
            member val Module = Unchecked.defaultof<string> with get, set
        
    
    [<Event("Upgraded")>]
    type UpgradedEventDTO() =
        inherit EventDTO()
            [<Parameter("address", "msgSender", 1, true )>]
            member val MsgSender = Unchecked.defaultof<string> with get, set
            [<Parameter("address", "newLogic", 2, true )>]
            member val NewLogic = Unchecked.defaultof<string> with get, set
        
    
    [<Event("Wiped")>]
    type WipedEventDTO() =
        inherit EventDTO()
            [<Parameter("address", "msgSender", 1, true )>]
            member val MsgSender = Unchecked.defaultof<string> with get, set
        
    
    [<FunctionOutput>]
    type AccessOutputDTO() =
        inherit FunctionOutputDTO() 
            [<Parameter("bytes", "", 1)>]
            member val public ReturnValue1 = Unchecked.defaultof<byte[]> with get, set
        
    
    [<FunctionOutput>]
    type CoreOutputDTO() =
        inherit FunctionOutputDTO() 
            [<Parameter("bool", "", 1)>]
            member val public ReturnValue1 = Unchecked.defaultof<bool> with get, set
        
    
    [<FunctionOutput>]
    type EmptyOutputDTO() =
        inherit FunctionOutputDTO() 
            [<Parameter("bool", "", 1)>]
            member val public ReturnValue1 = Unchecked.defaultof<bool> with get, set
        
    
    [<FunctionOutput>]
    type LatestOutputDTO() =
        inherit FunctionOutputDTO() 
            [<Parameter("address", "", 1)>]
            member val public ReturnValue1 = Unchecked.defaultof<string> with get, set
        
    
    
    
    [<FunctionOutput>]
    type LockedOutputDTO() =
        inherit FunctionOutputDTO() 
            [<Parameter("bool", "", 1)>]
            member val public ReturnValue1 = Unchecked.defaultof<bool> with get, set
        
    
    [<FunctionOutput>]
    type ModuleOutputDTO() =
        inherit FunctionOutputDTO() 
            [<Parameter("string", "", 1)>]
            member val public ReturnValue1 = Unchecked.defaultof<string> with get, set
        
    
    
    
    [<FunctionOutput>]
    type PreviousOutputDTO() =
        inherit FunctionOutputDTO() 
            [<Parameter("address", "", 1)>]
            member val public ReturnValue1 = Unchecked.defaultof<string> with get, set
        
    
    
    
    
    
    [<FunctionOutput>]
    type TimerSetOutputDTO() =
        inherit FunctionOutputDTO() 
            [<Parameter("bool", "", 1)>]
            member val public ReturnValue1 = Unchecked.defaultof<bool> with get, set
        
    
    [<FunctionOutput>]
    type TimestampOutputDTO() =
        inherit FunctionOutputDTO() 
            [<Parameter("uint64", "", 1)>]
            member val public ReturnValue1 = Unchecked.defaultof<ulong> with get, set
        
    
    
    
    
    
    
    
    [<FunctionOutput>]
    type VersionOutputDTO() =
        inherit FunctionOutputDTO() 
            [<Parameter("uint256", "", 1)>]
            member val public ReturnValue1 = Unchecked.defaultof<BigInteger> with get, set
        
    


