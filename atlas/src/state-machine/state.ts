


const State = () => {
  let signature: string;
  let condition: () => boolean;
  
  let permit: Map<string, Map<string, boolean>>;

  const getPermit = (sig: string, action: string): boolean | undefined => {
    let inner = permit.get(sig)
    return inner?.get(action);
  }

  const tryToTransition = (state: string) => {
    if (getPermit(state, "from")) {
      
    }
  }
}