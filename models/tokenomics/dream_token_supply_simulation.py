import plotly.graph_objects as go

# testing burn mechanics unlocks
# exponential vesting
# linear vesting
# testing incentive scheme

class Stat:
    def __init__(self, name, real):
        self.name = name
        self.real = real
        self.max = 0
        self.min = 0
        self.x = []
        self.y = []

    # config max value
    def configure_max(self, value):
        self.max = value
    
    def configure_min(self, value):
        self.min = value

    # this will not perform the addition if it overflows
    def add(self, value):
        # is above max and max has been configured
        if self.max != 0 and self.real + value >= self.max:
            # do nothing
            pass
            
        else:
            # update
            self.real += value
    
    # this will not perform the subtraction if it overflows
    def sub(self, value):
        # is below min
        if self.real - value <= self.min:
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
    
    def push_set(self, x, y):
        self.x.append(x)
        self.y.append(y)

stats = []
def push_new_stat(name, value):
    global stats
    stats.append(Stat(name, value))

stats_total_supply = []
def push_new_stat_total_supply(name, value):
    global stats_total_supply
    stats_total_supply.append(Stat(name, value))

def release(reference_total_supply, reference, value):
    global total_supply
    global stats
    stats[reference].sub(value)
    stats_total_supply[reference_total_supply].add(value)

months = 240

def push_new_set(reference, x, y):
    global stats
    stats[reference].push_set(x, y)

def push_new_set_total_supply(reference, x, y):
    global stats_total_supply
    stats_total_supply[reference].push_set(x, y)

push_new_stat_total_supply("Polkadex Total Supply", 0)
push_new_stat("Founders and Team", 1_800_000)
push_new_stat("Seed Round", 1_400_000)

quarter = 0
quarter_2 = 0
for month in range(months + 1):
    # POLKADEX
    if month == 12:
        release(0, 0, 360_000)

    # RELEASED QUARTERLY AFTER 12 MONTHS
    if month > 12:
        quarter += 1
        if quarter == 4:
            quarter = 0
            # ASSUMING 1 YEAR UNLOCK!
            release(0, 0, 360_000)
    
    release(0, 1, 280_000)

    quarter_2 += 1
    if quarter_2 == 4:
        quarter_2 = 0
        # ASSUMING 1 YEAR UNLOCK
        release(0, 1, 280_000)

    for i in range(len(stats)):
        push_new_set(i, month, stats[i].real)

    for i in range(len(stats_total_supply)):
        push_new_set_total_supply(i, month, stats_total_supply[i].real)

fig  = go.Figure()

for i in range(len(stats)):
    fig.add_trace(go.Scatter(x=stats[i].x, y=stats[i].y, mode="lines", name=stats[i].name))

for i in range(len(stats_total_supply)):
    fig.add_trace(go.Scatter(x=stats_total_supply[i].x, y=stats_total_supply[i].y, mode="lines", name=stats_total_supply[i].name))

# customize the layout
fig.update_layout(
    title='Tokenomics Simulation',
    xaxis_title='Months',
    yaxis_title='Supply',
    yaxis_type="log"
)

# display the plot
fig.show()