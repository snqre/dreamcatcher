import {EventEmitter} from "events";

interface Message {
  signature: () => string;
  
  content: () => object | void;

  setSignature: (signature: string) => Message;

  setContent: (content: () => object | void) => Message;
}

const message = (): () => Message => {
  const blueprint = (): Message => {
    let _signature: string;
    let _content: () => object | void;
    
    const signature = (): string => {
      return _signature;
    }

    const content = (): () => object | void => {
      return _content;
    }

    const setSignature = (signature: string): Message => {
      _signature = signature;
      return instance;
    }

    const setContent = (content: () => object | void): Message => {
      _content = content;
      return instance;
    }

    const instance: Message = {
      signature,
      content,
      setSignature,
      setContent
    }

    return instance;
  }

  return blueprint;
}

interface Sentinel {
  stream: () => EventEmitter;
  broadcast: (message: Message) => Sentinel;
  listenFor: (message: Message) => Sentinel;
}

const sentinel: () => Sentinel = ((): () => Sentinel => {
  let _instance: Sentinel;

  const blueprint = (): Sentinel => {
    let _stream: EventEmitter = new EventEmitter();

    setInterval(() => {
      broadcast(
        message()()
          .setSignature("<sentinel> --pulse")
          .setContent(() => {
            return {}
          })
      )
    }, 60_000);

    const stream = (): EventEmitter => {
      return _stream;
    }

    const broadcast = (message: Message): Sentinel => {
      stream().emit(message.signature(), message.content());
      return _instance;
    }

    const listenFor = (message: Message): Sentinel => {
      if (message.signature()) {
        stream().on(message.signature(), message.content);
      }
      return _instance;
    }

    return {
      stream,
      broadcast,
      listenFor
    }
  }

  return (): Sentinel => {
    if (!_instance) {
      _instance = blueprint();
    }
    return _instance;
  }
})();

sentinel()
  .listenFor(
    message()()
      .setSignature("<sentinel> --pulse")
      .setContent(() => {
        60000 * 29939;
      })
  )

interface State {
  signature: () => string;

  to: () => void;

  from: () => void;

  setSignature: (signature: string) => State;

  setTo: (to: () => void) => State;

  setFrom: (from: () => void) => State;
}

const state = (): () => State => {
  const blueprint = (): State => {
    let _signature: string;
    let _to: () => void;
    let _from: () => void;
    let _condition: () => boolean;

    const signature = (): string => {
      return _signature;
    }

    const to = (): () => void => {
      return _to;
    }

    const from = (): () => void => {
      return _from;
    }

    const condition = (): () => boolean => {
      return _condition;
    }

    const setSignature = (signature: string): State => {
      _signature = signature;
      return instance;
    }

    const setTo = (to: () => void): State => {
      _to = to;
      return instance;
    }

    const setFrom = (from: () => void): State => {
      _from = from;
      return instance;
    }

    const setCondition = (condition: () => boolean): State => {
      _condition = condition;
      return instance;
    }



    const instance: State = {
      signature,
      to,
      from,
      setSignature,
      setTo,
      setFrom
    }

    return instance;
  }

  return blueprint;
}

const automata = () => {
  const blueprint = () => {
    let _state: Array<State> = [];

    const addState = (state: State) => {
      
      _state.push(state);
    }

    return {}
  }
}