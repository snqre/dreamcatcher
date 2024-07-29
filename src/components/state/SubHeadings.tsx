class SubHeadings {
    private constructor() {}
    private static readonly _STORED: string[] = [
        "Finance isn't only for institutions, it's for you too",
        "Have you been here before?"
    ];

    public static selectRandom(): string {
        return SubHeadings._STORED[Math.round(Math.random() * SubHeadings._STORED.length - 1)];
    }
}

export {SubHeadings};