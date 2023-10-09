// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @dev A library providing functionality for working with Tag structs.
 */
library TagV1 {
    /**
    * @dev A struct representing a tag with caption, message, and creator information.
    */
    struct Tag {
        string caption;
        string message;
        address creator;
    }

    /**
    * @dev Public pure function to get the caption of a tag.
    * @param self The Tag struct.
    * @return string representing the caption of the tag.
    */
    function caption(Tag memory self) public pure returns (string memory) {
        return self.caption;
    }

    /**
    * @dev Public pure function to get the message of a tag.
    * @param self The Tag struct.
    * @return string representing the message of the tag.
    */
    function message(Tag memory self) public pure returns (string memory) {
        return self.message;
    }

    /**
    * @dev Public pure function to get the creator address of a tag.
    * @param self The Tag struct.
    * @return address representing the creator address of the tag.
    */
    function creator(Tag memory self) public pure returns (address) {
        return self.creator;
    }

    /**
    * @dev Public function to set the caption of a tag.
    * @param self The storage reference to the Tag struct.
    * @param caption The new caption to set.
    */
    function setCaption(Tag storage self, string memory caption) public {
        self.caption = caption;
    }

    /**
    * @dev Public function to set the message of a tag.
    * @param self The storage reference to the Tag struct.
    * @param message The new message to set.
    */
    function setMessage(Tag storage self, string memory message) public {
        self.message = message;
    }

    /**
    * @dev Public function to set the creator address of a tag.
    * @param self The storage reference to the Tag struct.
    * @param creator The new creator address to set.
    */
    function setCreator(Tag storage self, address creator) public {
        self.creator = creator;
    }
}