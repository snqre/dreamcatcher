import {Axios} from "axios";

class Material {
    
    /**
     * @throws ?
     */
    public static async bytecode(): Promise<string> {
        return (await new Axios().get("/bytecode")).data;
    }

    /** @throws ? */
    public static async abi(): Promise<object[]> {
        return (await new Axios().get("/abi")).data;
    }
}