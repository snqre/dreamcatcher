SPDX-License-Identifier: CC-BY-NC-SA-4.0

Dreamcatcher functions as a key. Some contracts can be designated as governance which allows them to call connect from dreamcatcher to access modules only dreamcatcher can access. Dreamcatcher also has permission to register a new contract as an upgraded version of another, meaning it has the capabilities of upgrading modules as well if called by a governance module.

To protect the protocol dreamcatcher cannot make external calls (meaning calls to none module contracts). But can call contracts that do, to do so, such as the Vault to send or recieve assets or trade them. Dreamcatcher functions as a key to these functions and features which are therefore only accesible through governance authorisation.