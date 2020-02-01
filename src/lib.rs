extern crate unicode_segmentation;
extern crate libc;

use unicode_segmentation::UnicodeSegmentation;

fn grapheme_indices(s: &str) -> Vec<(usize, &str)> {
    return UnicodeSegmentation::grapheme_indices(s, true).collect::<Vec<(usize, &str)>>();
}

fn graphemes(s: &str) -> Vec<&str> {
    return UnicodeSegmentation::graphemes(s, true).collect::<Vec<&str>>();
}

fn generate_bigrams(s: &str) -> Vec<&str> {
    let grapheme_indices = grapheme_indices(s);

    let mut vec: Vec<&str> = Vec::new();
    if grapheme_indices.len() < 2 {
        return vec;
    }

    for i in 0..grapheme_indices.len() - 1 {
        let start = grapheme_indices[i].0;
        let end = grapheme_indices[i + 1].0 + grapheme_indices[i + 1].1.len();
        vec.push(&s[start..end])
    }

    return vec;
}

fn with_case_ignored(s: &str, ignore_case: bool) -> String {
    if !ignore_case {
        return s.to_string();
    }

    return s.to_lowercase();
}

mod sorensen_dice {
    use crate::{with_case_ignored, generate_bigrams};
    use std::collections::HashMap;
    use std::collections::hash_map::Entry::{Occupied, Vacant};

    pub fn coefficient(a: &str, b: &str, ignore_case: bool) -> f64 {
        let case_handled = [with_case_ignored(&a, ignore_case), with_case_ignored(&b, ignore_case)];

        let a_bigrams = generate_bigrams(&case_handled[0]);
        let mut b_bigrams_hash: HashMap<&str, i64> = HashMap::new();

        let mut total_bigrams = a_bigrams.len();

        {
            let b_bigrams = generate_bigrams(&case_handled[1]);
            for s in &b_bigrams {
                let counter = b_bigrams_hash.entry(s).or_insert(0);
                *counter += 1;
            }

            total_bigrams += b_bigrams.len();
        }

        let mut intersections = 0;
        for bigram in &a_bigrams {
            match b_bigrams_hash.entry(bigram) {
                Vacant(_) => {},
                Occupied(entry) => {
                    let counter = entry.get();
                    if counter > &0 {
                        *entry.into_mut() = entry.get() - 1;
                        intersections += 1;
                    }
                },
            }
        }

        return 2.0 * intersections as f64 / total_bigrams as f64;
    }
}

mod jaro {
    use crate::{with_case_ignored, graphemes};
    use std::cmp;

    pub struct JaroSimilarityResult {
        pub value: f64,
        pub max_prefix_length: i64,
    }

    pub fn similarity(a: &str, b: &str, ignore_case: bool) -> JaroSimilarityResult {
        let case_handled = [with_case_ignored(&a, ignore_case), with_case_ignored(&b, ignore_case)];
        let mut graphemes = [graphemes(&case_handled[0]), graphemes(&case_handled[1])];
        if graphemes[0].len() > graphemes[1].len() {
            graphemes.swap(0, 1);
        }

        // let grapheme_iterators = [UnicodeSegmentation::graphemes(&case_handled[0][..], true), UnicodeSegmentation::graphemes(&case_handled[1][..], true)];
        let lengths = [graphemes[0].len(), graphemes[1].len()];

        let matching_dist = (cmp::max(lengths[0], lengths[1]) / 2) - 1;

        let mut b_matching_indices = Vec::with_capacity(cmp::max(lengths[0], lengths[1]));

        // Find matches
        let mut last_matched_prefix_index = -1;
        {
            let mut b_matched = vec![false; lengths[1]];
            for (i, &grapheme) in graphemes[0].iter().enumerate() {
                let start = cmp::max(0 as i64, i as i64 - matching_dist as i64) as usize;
                let end = cmp::min(lengths[1], i + matching_dist + 1);

                for j in start..end {
                    if grapheme == graphemes[1][j] && !b_matched[j] {
                        b_matched[j] = true;
                        b_matching_indices.push(j);

                        if (last_matched_prefix_index == -1 || last_matched_prefix_index == i as i64 - 1) && i == j {
                            last_matched_prefix_index = i as i64;
                        }

                        break;
                    }
                }
            }
        }

        let matches = b_matching_indices.len();
        if matches == 0 {
            return JaroSimilarityResult { value: 0.0, max_prefix_length: 0 };
        }

        // Find transpositions in matches
        let transpositions = b_matching_indices.windows(2).fold(0, |acc, pair| if pair[0] > pair[1] { acc + 1 } else { acc } );

        let m = matches as f64;
        let t = transpositions as f64;
        return JaroSimilarityResult {
            value: ((m / lengths[0] as f64) + (m / lengths[1] as f64) + ((m - t as f64) / m)) / 3.0,
            max_prefix_length: last_matched_prefix_index + 1
        };
    }
}

mod jaro_winkler {
    use crate::jaro;
    use std::cmp;

    pub fn similarity(a: &str, b: &str, ignore_case: bool, prefix_length: u32, prefix_scaling_factor: f64) -> f64 {
        let jaro_similarity = jaro::similarity(a, b, ignore_case);
        let common_prefix_len = cmp::min(prefix_length as i64, jaro_similarity.max_prefix_length);
        return jaro_similarity.value + common_prefix_len as f64 * prefix_scaling_factor * (1.0 - jaro_similarity.value);
    }
}

use libc::{c_char, c_double};
use std::ffi::CStr;

#[no_mangle]
pub extern fn sorensen_dice_coefficient_c(a: *const c_char, b: *const c_char, ignore_case: c_char) -> c_double {
    if a.is_null() || b.is_null() {
        return 0.0;
    }

    let a_c_str = unsafe { CStr::from_ptr(a) };
    let b_c_str = unsafe { CStr::from_ptr(b) };

    let a_str = match a_c_str.to_str() {
        Err(_e) => return 0.0,
        Ok(s) => s,
    };

    let b_str = match b_c_str.to_str() {
        Err(_e) => return 0.0,
        Ok(s) => s,
    };

    return sorensen_dice::coefficient(a_str, b_str, ignore_case == 1);
}

#[no_mangle]
pub extern fn jaro_similarity_c(a: *const c_char, b: *const c_char, ignore_case: c_char) -> c_double {
    if a.is_null() || b.is_null() {
        return 0.0;
    }

    let a_c_str = unsafe { CStr::from_ptr(a) };
    let b_c_str = unsafe { CStr::from_ptr(b) };

    let a_str = match a_c_str.to_str() {
        Err(_e) => return 0.0,
        Ok(s) => s,
    };

    let b_str = match b_c_str.to_str() {
        Err(_e) => return 0.0,
        Ok(s) => s,
    };

    return jaro::similarity(a_str, b_str, ignore_case == 1).value;
}

#[no_mangle]
pub extern fn jaro_winkler_similarity_c(a: *const c_char, b: *const c_char, ignore_case: c_char, prefix_length: u32, prefix_scaling_factor: c_double) -> c_double {
    if a.is_null() || b.is_null() {
        return 0.0;
    }

    let a_c_str = unsafe { CStr::from_ptr(a) };
    let b_c_str = unsafe { CStr::from_ptr(b) };

    let a_str = match a_c_str.to_str() {
        Err(_e) => return 0.0,
        Ok(s) => s,
    };

    let b_str = match b_c_str.to_str() {
        Err(_e) => return 0.0,
        Ok(s) => s,
    };

    return jaro_winkler::similarity(
        a_str,
        b_str,
        ignore_case == 1,
        prefix_length,
        prefix_scaling_factor
    );
}

#[no_mangle]
pub extern fn jaro_winkler_distance_c(a: *const c_char, b: *const c_char, ignore_case: c_char, prefix_length: u32, prefix_scaling_factor: c_double) -> c_double {
    return 1.0 - jaro_winkler_similarity_c(a, b, ignore_case, prefix_length, prefix_scaling_factor);
}
