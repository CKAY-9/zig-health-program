const std = @import("std");

// Person is a struct (collection of values and functions) that will be used for keeping track of informaiton
const Person = struct {
    kilograms: f16 = 75, // f16 refers to a floating point number (a number with a decimal) that is assigned 16 bits (2^16)
    height_meters: f16 = 1.75,
    age: u8 = 18, // u8 refers to a unsigned integer (only numbers >= 0) that is given 8 bits (2^8)
    name: [128]u8 = undefined,
    activity: u4 = 1, // 2^4
    male: bool, // booleans are true or false

    // in the coding language zig, init is used for creating a struct with values
    pub fn init(kilograms: f16, height_meters: f16, age: u8, name: [128]u8, activity: u4, male: bool) Person {
        return Person{ .kilograms = kilograms, .height_meters = height_meters, .age = age, .name = name, .activity = activity, .male = male };
    }

    // fn is a function and takes a parameters (in this case a pointer to a person)
    // pub makes the function public and able to be called from outside the object
    pub fn calculateBodyMassIndex(self: *Person) f16 { // having f16 here tells zig, and other programmers, that this func will return an 2^16 float
        return self.kilograms / (self.height_meters * self.height_meters); // return returns a value
    }

    pub fn calculateBaseMetabolicRate(self: *Person) f16 {
        if (self.male) {
            return 10 * self.kilograms + 6.25 * (self.height_meters * 100) - 5 * @as(f16, @floatFromInt(self.age)) + 5;
        }
        return 10 * self.kilograms + 6.25 * (self.height_meters * 100) - 5 * @as(f16, @floatFromInt(self.age)) - 161;
    }

    pub fn calculateCalorieIntake(self: *Person) f16 {
        var bmr: f16 = self.calculateBaseMetabolicRate();
        var activity_rate: f16 = switch (self.activity) { // a switch case allows us to return a value based off an input, this varies from language
            2 => 1.375,
            3 => 1.55,
            4 => 1.725,
            5 => 1.9,
            else => 1.2,
        };
        return bmr * activity_rate;
    }

    pub fn printInfo(self: *Person) !void {
        const stdout = std.io.getStdOut().writer();
        try stdout.print("{s}'s Information:\n", .{self.name});
        try stdout.print(" - Age: {d}\n", .{self.age});
        try stdout.print(" - Weight: {d}kg\n", .{self.kilograms});
        try stdout.print(" - Height: {d}cm\n", .{self.height_meters * 100});
        var sex_output: [6]u8 = undefined;
        if (self.male) {
            // mem.copy copies a different value into the same allocated memory allowing overwriting
            std.mem.copy(u8, &sex_output, "Male");
        } else {
            std.mem.copy(u8, &sex_output, "Female");
        }
        try stdout.print(" - Sex: {s}\n", .{sex_output});
        try stdout.print(" - BMI: {d}\n", .{self.calculateBodyMassIndex()});
        try stdout.print(" - Caloric Intake: {d}\n", .{self.calculateCalorieIntake()});
    }

    pub fn saveDataToFile(self: *Person) !void {
        _ = self;
        _ = std.fs.cwd().makeDir("saves") catch |e|
            switch (e) {
            error.PathAlreadyExists => {
                return;
            },
            else => return e,
        };
        var file = std.fs.cwd().createFile("saves/saves.txt", .{}) catch |e|
            switch (e) {
            error.PathAlreadyExists => {
                return;
            },
            else => return e,
        };
        defer file.close();
    }
};

pub fn main() !void {
    var buf: [128]u8 = undefined; // user input

    // user inputs
    var kg: f16 = 75;
    var height: f16 = 1.75;
    var age: u8 = 18;
    var name: [128]u8 = undefined;
    var activity: u4 = 1;
    var male: bool = false;

    const stdin = std.io.getStdIn().reader(); // used for getting console inputs
    const stdout = std.io.getStdOut().writer(); // used for console outputs

    // get user inputs
    // try in zig is a "shortcut" for dealing with errors
    try stdout.print("Name: ", .{});
    if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |name_input| {
        std.mem.copy(u8, &name, name_input);
    }

    try stdout.print("Age: ", .{});
    if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |age_input| {
        age = try std.fmt.parseUnsigned(u8, age_input, 10);
    }

    try stdout.print("Weight (kilograms): ", .{});
    if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |weight_input| {
        kg = try std.fmt.parseFloat(f16, weight_input);
    }

    try stdout.print("Height (meters): ", .{});
    if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |height_input| {
        height = try std.fmt.parseFloat(f16, height_input);
    }

    try stdout.print("Activity (1-5): ", .{});
    if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |activity_input| {
        activity = try std.fmt.parseUnsigned(u4, activity_input, 10);
    }

    try stdout.print("Biological Sex (m/f): ", .{});
    if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |sex_input| {
        if (std.mem.eql(u8, sex_input, "m")) {
            male = true;
        }
    }

    // create a new person with the user specified info
    var person = Person.init(kg, height, age, name, activity, male);
    try person.printInfo();

    try stdout.print("Save information to file (y/n): ", .{});
    if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |save_input| {
        if (std.mem.eql(u8, save_input, "y")) {
            try person.saveDataToFile();
        }
    }
}
