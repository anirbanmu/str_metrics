extern crate itertools;
extern crate unicode_segmentation;

use itertools::Itertools;
use unicode_segmentation::UnicodeSegmentation;

mod array_2d;
pub use array_2d::Array2D;

pub fn graphemes(s: &str) -> Vec<&str> {
    UnicodeSegmentation::graphemes(s, true).collect::<Vec<&str>>()
}

pub fn generate_bigrams(s: &str) -> Vec<&str> {
    UnicodeSegmentation::grapheme_indices(s, true)
        .tuple_windows()
        .map(|(a, b)| &s[a.0..b.0 + b.1.len()])
        .collect::<Vec<&str>>()
}
