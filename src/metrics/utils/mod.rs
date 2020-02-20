extern crate itertools;
extern crate unicode_segmentation;

use itertools::Itertools;
use unicode_segmentation::UnicodeSegmentation;

mod array_2d;
pub use array_2d::Array2D;

pub fn graphemes(s: &str) -> Vec<&str> {
    return UnicodeSegmentation::graphemes(s, true).collect::<Vec<&str>>();
}

pub fn generate_bigrams(s: &str) -> Vec<&str> {
    UnicodeSegmentation::grapheme_indices(s, true)
        .tuple_windows()
        .map(|(a, b)| &s[a.0..b.0 + b.1.len()])
        .collect::<Vec<&str>>()
}

pub fn with_case_ignored(s: &str, ignore_case: bool) -> String {
    if !ignore_case {
        return s.to_string();
    }

    return s.to_lowercase();
}
