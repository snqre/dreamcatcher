export interface Queue {
  put: (data: any) => any,
  pull: () => any,
  size: () => number
}

export const queue: () => Queue = (): Queue => {
  let myQueue: Array<any>;

  const put = (data: any): any => {
    myQueue.push(data);
    return this;
  }

  const pull = (): any => {
    return myQueue.shift();
  }

  const size = (): number => {
    return myQueue.length;
  }

  return {
    put,
    pull,
    size
  };
}