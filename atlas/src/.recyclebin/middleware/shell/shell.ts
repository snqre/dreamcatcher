import * as chalk from "chalk";
import * as readline from "readline";
import * as queue from "../../structure/queue.js";
import * as event from "events";

export const emit = new event.EventEmitter();
emit.emit("starting");
emit.on("starting", () => {
  
});

interface Shell {
  ask: (question: string, callback: (response: string) => void) => void;
}

const shell: () => Shell = ((): () => Shell => {
  let instance: Shell;

  const blueprint = (): Shell => {
    let myQueue: queue.Queue;
    let myIsListening: boolean;
    let MyState: any = {
      IS_IDLE: "IS_IDLE",
      IS_PROCESSING_QUEUE: "IS_PROCESSING_QUEUE"
    }
    let myState: string = MyState.IS_IDLE;

    const queueSize = (): number => {
      return myQueue.size();
    }

    const isListening = (): boolean => {
      return myIsListening;
    }

    const isIdle = (): boolean => {
      return myState === MyState.IS_IDLE;
    }

    const isProcessingQueue = (): boolean => {
      return myState === MyState.IS_PROCESSING_QUEUE;
    }

    const run = () => {

    }

    const post = async (question: string, callback: (response: string) => void): Promise<any> => {
      if (isIdle()) {
        myState = MyState.IS_PROCESSING_QUEUE;
        const prompt = readline.createInterface({input: process.stdin, output: process.stdout});
        prompt.question(question, (answer) => {
          callback(answer);
          prompt.close();
          
        });
      }
      myQueue.put({
        question: question,
        callback: callback
      });
      if (isListening()) {
        process();
      }
      return ;
    }

    const ask = (question: string, callback: (response: string) => void): typeof instance => {
      const prompt = readline.createInterface({
        input: process.stdin,
        output: process.stdout
      });
      prompt.question(question, (answer) => {
        callback(answer);
        prompt.close();
      });
      return instance;
    }

    /// *await _sleep
    const _sleep = (ms: number): Promise<unknown> => new Promise((response: (value: unknown) => void): NodeJS.Timeout => setTimeout(response, ms));

    return {
      ask
    };
  }

  return (): Shell => {
    if (!instance) {
      instance = blueprint();
    }
    return instance;
  }
})();

shell().ask("please write down seed", (response) => {
  console.log(response);
})
shell().ask("Hello", (response) => {
  console.log("he");
});