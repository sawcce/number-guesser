const std = @import("std");
const RndGen = std.rand.DefaultPrng;

const amount_of_tries: u8 = 10;

pub fn main() !void {
    var seed: u64 = undefined;
    try std.os.getrandom(std.mem.asBytes(&seed));

    var rnd = RndGen.init(seed);
    var number_to_guess = rnd.random().int(u8);

    var i: u8 = 0;

    std.debug.print("\nGuess a number between 0 and 255!\n", .{});

    while (i < amount_of_tries) : (i += 1) {
        const guessed_num = try get_number(u8);

        if (guessed_num < number_to_guess) {
            std.debug.print("Number too small! Try again.\n", .{});
        } else if (guessed_num > number_to_guess) {
            std.debug.print("Number too big! Try again.\n", .{});
        } else {
            break;
        }

        std.debug.print("{} tries left!\n", .{amount_of_tries - i - 1});
    }

    if (i == 9) {
        std.debug.print("You lost! The number was: {}", .{number_to_guess});
    } else {
        std.debug.print("You won! ({} tries)", .{i + 1});
    }
}

fn get_number(comptime number_type: type) !number_type {
    const stdin = std.io.getStdIn().reader();
    const allocator = std.heap.page_allocator;

    while (true) {
        std.debug.print("Enter number: ", .{});

        // We read from stdin, handle any StreamTooLong errors and return any unexpected ones
        const read = stdin.readUntilDelimiterOrEofAlloc(allocator, '\n', 50) catch |err| {
            if (err == error.StreamTooLong) {
                std.debug.print("Input too long!\n", .{});
                continue;
            } else {
                return err;
            }
        };

        if (read) |value| {
            // To take in account systems using CRLF line endings we need to
            // trim any trailing '\r' characters
            const line = std.mem.trimRight(u8, value, "\r");

            // Parses the int and asks again for input in case of int overflow
            return std.fmt.parseInt(number_type, line, 10) catch |err| {
                if (err == error.Overflow) {
                    std.debug.print("Number out of bounds (number is always smaller than 256) please enter a new input!\n", .{});
                    continue;
                } else {
                    return err;
                }
            };
        }

        continue;
    }
}
