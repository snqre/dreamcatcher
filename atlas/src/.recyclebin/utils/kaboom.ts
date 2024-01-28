

interface Kaboom {

}

interface Wrapper {

}

/// focuses on diffusing errors
const kaboom: () => Kaboom = ((): () => Kaboom => {
  let instance: Kaboom;

  const blueprint = (): Kaboom => {
    let _logs: Array<any>;

    const error = () => {
      let _module: () => any;
      let _error: any;

      const module = (): any => {
        return _module;
      }

      const error = (): any => {
        return _error;
      }

      return {
        module,
        error
      }
    }

    const wrap: Wrapper = (program: () => any) => {
      const _program: () => any = program;
      let _willContainException: boolean;
      let _keepRetrying: boolean;
      let _ignore: boolean;
      let _revert: boolean;
      let _error: any | undefined;
      let _result: any;

      const unwrap = () => {
        return _program;
      }

      const result = () => {
        return _result;
      }

      const willContainExeception = () => {
        return _willContainException;
      }

      const error = () => {
        return _error;
      }

      const execute = () => {
        return unwrap()();
      }

      const diffuse = (success: (result: any) => void, kaboom: (error: any) => void) => {
        let result: any;
        try {
          result = execute();
          success(result)
        }
        catch (error: unknown) {
          _error = error;
          kaboom(error);
        }
      }

      const expectRange = (min: number, max: number) => {
        if (result() < min || result() > max) {
          
        }
      }

      return {};
    }

    const unwrap = (subproc: () => any, handle: (error: any) => void) => {
      let result: object;
      try {
        result = {
          success: subproc(),
          
        }
        subproc();
      }
      catch (error) {
        _logs.push(error);
        handle(error);
      }
    }

    const retry = async (subproc: () => any, wait: number, retry: number): Promise<any> => {
      let logs: Array<any> = [];
      while (retry !== 0) {
        try {
          return subproc();
        }
        catch (error) {
          logs.push(error);
        }

        retry -= 1;

        await _sleep(wait);
      }
      return logs;
    }

      

      unwrap(subproc, (error: any) => {
        while (tries !== 0) {
          unwrap(subproc, () => {});
          tries -= 1;
        }
      })

    }

    const _sleep = (ms: number): Promise<void> => {
      return new Promise<void>((resolve: (value: void | PromiseLike<void>) => void): void => {
        setTimeout(resolve, ms);
      });
    }
    
    return {};
  }

  return (): Kaboom => {
    if (!instance) {
      instance = blueprint();
    }
    return instance;
  }
})();