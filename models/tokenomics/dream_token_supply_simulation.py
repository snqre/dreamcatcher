import plotly.graph_objects as go

# testing burn mechanics unlocks
# exponential vesting
# linear vesting
# testing incentive scheme

class Stat:
    def __init__(self, real):
        self.real = real
        self.max = 0
        self.min = 0

    # config max value
    def configMax(self, value):
        self.max = value
    
    def configMin(self, value):
        self.min = value

    # this will not perform the addition if it overflows
    def add(self, value):
        # is above max and max has been configured
        if self.max != 0 and self.real + value > self.max:
            # do nothing
            pass
            
        else:
            # update
            self.real += value
    
    # this will not perform the subtraction if it overflows
    def sub(self, value):
        # is below min
        if self.real - value > self.min:
            # do nothing
            pass

        else:
            # update
            self.real -= value
    
    def mul(self, value):
        # is above max
        if self.real * value > self.max:
            # do nothing
            pass

        else:
            # update
            self.real *= value
    
    def div(self, value):
        # is below min
        if self.real / value < self.min:
            # do nothing
            pass

        else:
            # update
            self.real /= value

stats = []
def createNewStat(value):
    global stats
    stats.append(Stat(value))

totalSupply = Stat(0)
def release(reference, value):
    global totalSupply
    global stats
    stats[reference].sub(value)
    totalSupply.add(value)

months = 240
months:int = 240

createNewStat(40_000_000)
createNewStat(40_000_000)


months:int = 240
teamVestedWallets = Stat(40_000_000)
linearlyUnlockedPerMonth:float = teamVestedWallets.real / months.real

x = []
y = []
x1 = []
y1 = []
for month in range(months + 1):
    release(0, 100_000)
    release(1, 235_000)

    x.append(month)
    y.append(totalSupply.real)

    x1.append(month)
    y1.append(stats[1].real)

# create a line plot
fig = go.Figure(data=go.Scatter(x=x, y=y, mode='lines'))
fig = go.Figure(data=go.Scatter(x=x1, y=y1, mode='lines'))

# customize the layout
fig.update_layout(
    title='My Plot',
    xaxis_title='X-axis',
    yaxis_title='Y-axis'
)

# display the plot
fig.show()