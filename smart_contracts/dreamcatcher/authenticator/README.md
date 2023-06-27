The authenticator is a single contract that tracks who has what authority, as such it is a COREContract within the polygon contracts. The Authenticator has been designed to be flexible, as such should not need to be upgraded but in the eventuallity it does, the DAO must pay obsessive attention what code is implemented here

The Authenticator is an inherited contract of the Terminal. All Dreamcatcher contracts refer back to the Terminal for authentication. The Terminal is the single most important contract on each blockchain, in the future we will integrate cross chain communication from Terminal to Terminal. This will allow for Authentication on multiple chains to be standardized, we may not use addresses anymore but a different form of verification

All contracts refer back to this for authentication
eg. SingleStatePool > MiraiTerminal > DreamcatcherTerminal
