const std = @import("std");

pub const Colours = struct {
    pub const BLACK = Colour { .r = 0, .g = 0, .b = 0 };
    pub const WHITE = Colour { .r = 1, .g = 1, .b = 1 };
    pub const SKY = Colour { .r = 0.5, .g = 0.7, .b = 1 };
};

pub const Colour = struct {
    r: f64,
    g: f64,
    b: f64,
    a: f64 = 1.0,

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
