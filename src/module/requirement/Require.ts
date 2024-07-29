class Requirement extends Error {
    public static isRequirement(item: unknown): item is Requirement {
        return item instanceof Requirement;
    }

    public constructor(condition: boolean, reason?: string) {
        super(reason);
        if (!condition) {
            throw this;
        }
    }
}

export { Requirement };