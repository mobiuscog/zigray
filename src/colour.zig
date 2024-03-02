const std = @import("std");

pub const Colour = struct {
    r: f64,
    g: f64,
    b: f64,
    a: f64 = 1.0,

    pub const Colours = struct {
        pub const BLACK = Colour.init(0, 0, 0);
        pub const WHITE = Colour.init(1, 1, 1);
        pub const SKY = Colour.init(0.5, 0.7, 1);
        pub const RED = Colour.init(1, 0, 0);
    };

    pub fn init(red: f64, green: f64, blue: f64) Colour {
        return .{ .r = red, .g = green, .b = blue, };
    }

    pub fn add(self: Colour, other: Colour) Colour {
        return Colour {
            .r = clamp(self.r + other.r),
            .g = clamp(self.g + other.g),
            .b = clamp(self.b + other.b),
            .a = self.a,
        };
    }

    pub fn multiply(self: Colour, scalar: f64) Colour {
        return Colour {
            .r = clamp(self.r * scalar),
            .g = clamp(self.g * scalar),
            .b = clamp(self.b * scalar),
            .a = self.a,
        };
    }

    fn clamp(value: f64) f64 {
        return @min(1.0, @max(0.0, value));
    }
};
