Idea

$ moveFunds() ex {{
    ERC20 0x4048388bn894894 -> 9x88748780408087873;
}}

.> fundMe() ex {{
    move
}}

$ _onlyOwner() in {{
    auth => {

    }
}}

{
    [] [] []
    [] [] []
    [] [] []
}
= [a|1] = 4;

TradingBot.cth


$move()


$ open window.timelock

$ window.timelock show: {{ executed }}

% this is what a comment might look like

$ set announcement interval 6 hours


# log and global events
In this language there are global events and each function can listen to all.
Every function in this language produces an event in this style
$Account.setTrade(given params, result);
This allows event driven architecture, one event might trigger a chain reaction
and so on. This is really good for quant trading or fund management.

# functions that carry the modifier "listen" [ list of events with support for || and && operations ] trigger the following {{  }}. This can still be called like normal functions


# NORMAL FUNCTION
flow setTrade(int amount) {{
    <chain:ETH> <type:ERC20> <addressFrom> -> <addressTo>;
}}

# NORMAL FUNCTION
flow doSomethingElse() {{

}}

# EVENT DRIVEN
flow setTrade(int amount) listen [$Event1 && $Event2 || $Event3] {{
    doSomethingElse();
}}