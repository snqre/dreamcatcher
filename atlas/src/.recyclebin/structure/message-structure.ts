export interface Message  {
  signature: () => string;

  content: () => object;

  task: () => void;

  setSignature: (signature: string) => Message;

  setContent: (content: object) => Message;

  setTask: (task: () => void) => Message;

  build: () => Message;
}

export const message = () => {
  const _ = () => {
    let _signature: string;
    let _content: object;
    let _task: () => void;

    const signature = () => {
      return _signature;
    }

    const content = () => {
      return _content;
    }

    const task = () => {
      return _task;
    }

    const setSignature = (signature: string): Message => {
      _signature = signature;
      return _();
    }

    const setContent = (content: object): Message => {
      _content = content;
      return _();
    }

    const setTask = (task: () => void): Message => {
      _task = task;
      return _();
    }

    const build = (): Message => {
      if (!signature()) {
        throw new Error("message cannot be built because a signature has not been assigned");
      }
      if (content() && task()) {
        throw new Error("message cannot be built because it cannot carry both content and a task but has been given both");
      }
      return _();
    }

    return {
      signature,
      content,
      task,
      setSignature,
      setContent,
      setTask,
      build
    }
  }

  return (): Message => _();
}