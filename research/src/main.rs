#[allow(non_snake_case)]
#[allow(dead_code)]

fn main() {
    let mut engine = Engine {
        performance: 0,
        model: ""
            .to_string(),
    };
    engine
        .increasePerformance(60)
        .increasePerformance(20);
    let mut tesla = Car {
        minSpeed: 0,
        maxSpeed: 0,
        engine: engine,
    };
    println!(
        "{:?} {:?} {:?}",
        tesla
            .setMaxSpeed(90)
            .maxSpeed(),
        tesla
            .setMinSpeed(60)
            .minSpeed(),
        tesla
            .enginePerformance()
    )
}

struct Engine {
    performance: u8,
    model: String,
} impl Engine {
    fn performance(&self) -> u8 {
        return self
            .performance
            .clone();
    }

    fn model(&self) -> String {
        return self
            .model
            .clone();
    }

    fn increasePerformance(&mut self, value: u8) -> &mut Self {
        self
            .performance += value;
        return self;
    }

    fn rename(&mut self, name: String) -> &mut Self {
        self
            .model = name;
        return self;
    }
}

struct Car {
    minSpeed: u8,
    maxSpeed: u8,
    engine: Engine,
} impl Car {
    fn minSpeed(&self) -> u8 {
        return self
            .minSpeed
            .clone();
    }

    fn maxSpeed(&self) -> u8 {
        return self
            .maxSpeed
            .clone();
    }

    fn enginePerformance(&self) -> u8 {
        return self
            .engine
            .performance
            .clone();
    }

    fn setMinSpeed(&mut self, newMinSpeed: u8) -> &mut Self {
        self.minSpeed = newMinSpeed;
        return self;
    }

    fn setMaxSpeed(&mut self, newMaxSpeed: u8) -> &mut Self {
        self.maxSpeed = newMaxSpeed;
        return self;
    }
}

