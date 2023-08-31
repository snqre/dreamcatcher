# THIS IS TERRIBLE BUT ITS IT WORKS.
import plotly.graph_objects as go
import numpy as np
import math

class Wallet:
    def __init__(self, purpose, vestedAmount):
        self.purpose = purpose
        self.vestedAmount = vestedAmount
        self.min = 0
        self.max = 0
        self.minIsEnabled = True
        self.maxIsEnabled = False
        self.x = []
        self.y = []
    
    def pushSet(self, x, y):
        self.x.append(x)
        self.y.append(y)

class Token:
    def __init__(self, name, maxSupply):
        self.name = name
        self.maxSupply = maxSupply
        self.totalSupply = 0
        self.burnedSupply = 0
        self.mintedSupply = 0
        self.vestingWallets = []
        self.vestingWalletFinder = {}
        self.x = []
        self.y = []

    def createNewWallet(self, purpose, vestedAmount):
        wallet = Wallet(purpose, vestedAmount)
        self.vestingWallets.append(wallet)
        index = self.vestingWallets.index(wallet)
        # for humans : )
        self.vestingWalletFinder[purpose] = index

    def release(self, purpose, amount):
        index = self.vestingWalletFinder[purpose]
        remaining = self.vestingWallets[index].vestedAmount - self.vestingWallets[index].min
        if remaining < amount:
            self.vestingWallets[index].vestedAmount -= remaining
            self.totalSupply += remaining

        else:
            self.vestingWallets[index].vestedAmount -= amount
            self.totalSupply += amount
    
    def pushSet(self, x, y):
        self.x.append(x)
        self.y.append(y)

class Simulation:
    def __init__(self, months):
        self.months = months

simulation = Simulation(240)
exampleTankVestingSchedule = Token("ExampleToken", 100_000)

exampleTankVestingSchedule.createNewWallet("Team", 20_000)
exampleTankVestingSchedule.createNewWallet("Investors", 30_000)
exampleTankVestingSchedule.createNewWallet("Advisors", 5_000)
exampleTankVestingSchedule.createNewWallet("Ecosystem", 15_000)
exampleTankVestingSchedule.createNewWallet("Community", 15_000)
exampleTankVestingSchedule.createNewWallet("Liquidity", 15_000)

dreamToken = Token("DreamToken", 200_000_000)
dreamToken.createNewWallet("General", 200_000_000)

startValue = 100
growthRate = 0.1
quarter = 0
for month in range(simulation.months):
    if month == 12:
        exampleTankVestingSchedule.release("Team", 5_000)

    if month == 6:
        exampleTankVestingSchedule.release("Investors", 6_000)
    
    quarter += 1
    if quarter == 4:
        if month > 12:
            exampleTankVestingSchedule.release("Team", 416.60)

        if month > 6:
            exampleTankVestingSchedule.release("Investors", 1333.30)
        
        quarter = 0

    if month <= 24:
        exampleTankVestingSchedule.release("Advisors", 208.30)
        exampleTankVestingSchedule.release("Ecosystem", 625)

    if month <= 6:
        exampleTankVestingSchedule.release("Community", 2_500)
    
    for i in range(len(exampleTankVestingSchedule.vestingWallets)):
        vestedAmount = exampleTankVestingSchedule.vestingWallets[i].vestedAmount
        exampleTankVestingSchedule.vestingWallets[i].pushSet(month, vestedAmount)
    
    totalSupply = exampleTankVestingSchedule.totalSupply
    maxSupply = exampleTankVestingSchedule.maxSupply
    exampleTankVestingSchedule.pushSet(month, (totalSupply / maxSupply) * 100)

    if dreamToken.totalSupply < 200_000_000:
        if month == 0:
            dreamToken.totalSupply += 20_000_000

        totalSupply = dreamToken.totalSupply
        dreamToken.totalSupply = totalSupply + ((totalSupply / 100) * 1)

        totalSupply = dreamToken.totalSupply
        maxSupply = dreamToken.maxSupply
        dreamToken.pushSet(month, (totalSupply / maxSupply) * 100)

fig = go.Figure()

fig.add_trace(go.Scatter(x=exampleTankVestingSchedule.x, y=exampleTankVestingSchedule.y, mode="lines", name=exampleTankVestingSchedule.name))
fig.add_trace(go.Scatter(x=dreamToken.x, y=dreamToken.y, mode="lines", name=dreamToken.name))

# customize the layout
fig.update_layout(
    title='Tokenomics Simulation',
    xaxis_title='Months',
    yaxis_title='Supply',
    yaxis_type="log"
)

# display the plot
fig.show()