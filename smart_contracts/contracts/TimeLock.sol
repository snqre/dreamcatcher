/*



 */

contract TimeLock {
    struct Lock {
        string caption;
        uint256 start;
        uint256 end;
        uint256 duration;
        bool locked;
    }

    mapping(string => Lock) private locks;

    function fetchTimeLock(string memory _caption) internal returns (Lock) {
        return locks[_caption];
    }

    function newTimeLock(string memory _caption, uint256 _duration) internal {
        Lock lock;
        lock.caption = _caption;
        lock.start = block.timestamp;
        lock.end = lock.start + _duration;
        lock.locked = true;
        
    }

    function unlockTimeLock(string memory _caption) internal {
        /*
            will set the TimeLock locked to false if unlocked || true if still locked
         */
        uint256 current = block.timestamp;
        uint256 end = locks[_caption].end;
        bool locked = locks[_caption].locked;
        require(current >= end, "Not time yet");
        locked = false;
        locks[_caption].locked = locked;
    }
}
