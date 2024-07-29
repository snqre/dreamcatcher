import Axios from "axios";

async function fetch(url: string): Promise<unknown> {
    return (await Axios.get(url)).data;
}

async function post(url: string, data?: any): Promise<unknown> {
    return (await Axios.post(url, data)).data;
}

export { fetch };
export { post };