extern crate itertools;
extern crate libc;
extern crate unicode_segmentation;

use itertools::Itertools;
use unicode_segmentation::UnicodeSegmentation;

fn graphemes(s: &str) -> Vec<&str> {
    return UnicodeSegmentation::graphemes(s, true).collect::<Vec<&str>>();
}

fn generate_bigrams(s: &str) -> Vec<&str> {
    UnicodeSegmentation::grapheme_indices(s, true)
        .tuple_windows()
        .map(|(a, b)| &s[a.0..b.0 + b.1.len()])
        .collect::<Vec<&str>>()
}

fn with_case_ignored(s: &str, ignore_case: bool) -> String {
    if !ignore_case {
        return s.to_string();
    }

    return s.to_lowercase();
}

mod sorensen_dice {
    use crate::generate_bigrams;
    use std::collections::hash_map::Entry::{Occupied, Vacant};
    use std::collections::HashMap;

    pub fn coefficient(a: &str, b: &str, ignore_case: bool) -> f64 {
        if ignore_case {
            let case_handled = [a.to_lowercase(), b.to_lowercase()];
            return coefficient_impl(&case_handled[0], &case_handled[1]);
        }
        return coefficient_impl(a, b);
    }

    pub fn coefficient_impl(a: &str, b: &str) -> f64 {
        let a_bigrams = generate_bigrams(&a);
        let mut b_bigrams_hash: HashMap<&str, i64> = HashMap::new();

        let mut total_bigrams = a_bigrams.len();

        {
            let b_bigrams = generate_bigrams(&b);
            for s in &b_bigrams {
                let counter = b_bigrams_hash.entry(s).or_insert(0);
                *counter += 1;
            }

            total_bigrams += b_bigrams.len();
        }

        let mut intersections = 0;
        for bigram in &a_bigrams {
            match b_bigrams_hash.entry(bigram) {
                Vacant(_) => {}
                Occupied(entry) => {
                    let counter = entry.get();
                    if counter > &0 {
                        *entry.into_mut() = entry.get() - 1;
                        intersections += 1;
                    }
                }
            }
        }

        return 2.0 * intersections as f64 / total_bigrams as f64;
    }
}

mod jaro {
    use crate::{graphemes, with_case_ignored};
    use std::cmp;

    pub struct JaroSimilarityResult {
        pub value: f64,
        pub max_prefix_length: i64,
    }

    pub fn similarity(
        a: &str,
        b: &str,
        ignore_case: bool,
        compare_by_graphemes: bool,
    ) -> JaroSimilarityResult {
        if ignore_case {
            let case_handled = [with_case_ignored(&a, true), with_case_ignored(&b, true)];
            if compare_by_graphemes {
                let graphemes = [graphemes(&case_handled[0]), graphemes(&case_handled[1])];
                return similarity_impl(&graphemes[0], &graphemes[1]);
            }
            return similarity_impl(
                &case_handled[0].chars().collect::<Vec<char>>(),
                &case_handled[1].chars().collect::<Vec<char>>(),
            );
        }

        if compare_by_graphemes {
            let graphemes = [graphemes(a), graphemes(b)];
            return similarity_impl(&graphemes[0], &graphemes[1]);
        }

        return similarity_impl(
            &a.chars().collect::<Vec<char>>(),
            &b.chars().collect::<Vec<char>>(),
        );
    }

    pub fn similarity_impl<T: Eq>(a: &Vec<T>, b: &Vec<T>) -> JaroSimilarityResult {
        let mut graphemes = [a, b];
        if graphemes[0].len() > graphemes[1].len() {
            graphemes.swap(0, 1);
        }

        // let grapheme_iterators = [UnicodeSegmentation::graphemes(&case_handled[0][..], true), UnicodeSegmentation::graphemes(&case_handled[1][..], true)];
        let lens = [graphemes[0].len(), graphemes[1].len()];

        let max_length = cmp::max(lens[0], lens[1]);
        let matching_dist = (max_length / 2) - 1;

        let mut matching_indices = [
            Vec::with_capacity(max_length),
            Vec::with_capacity(max_length),
        ];

        // Find matches
        let mut last_matched_prefix_index = -1;
        {
            let mut b_matched = vec![false; lens[1]];
            for (i, grapheme) in graphemes[0].iter().enumerate() {
                let start = cmp::max(0 as i64, i as i64 - matching_dist as i64) as usize;
                let end = cmp::min(lens[1], i + matching_dist + 1);

                // Keep track of prefix match
                // Safe to access i in b since a.len < b.len
                if grapheme == &graphemes[1][i]
                    && ((last_matched_prefix_index == -1 && i == 0)
                        || last_matched_prefix_index == i as i64 - 1)
                {
                    last_matched_prefix_index = i as i64;
                }

                for j in start..end {
                    if grapheme == &graphemes[1][j] && !b_matched[j] {
                        b_matched[j] = true;
                        matching_indices[0].push(i);
                        matching_indices[1].push(j);
                        break;
                    }
                }
            }
        }

        let matches = matching_indices[0].len();
        if matches == 0 {
            return JaroSimilarityResult {
                value: 0.0,
                max_prefix_length: 0,
            };
        }

        // Find transpositions / 2 in matches
        matching_indices[1].sort_unstable();
        let transpositions = matching_indices[0]
            .iter()
            .zip(matching_indices[1].iter())
            .fold(0.0, |acc, (i, j)| {
                if graphemes[0][*i] == graphemes[1][*j] {
                    acc
                } else {
                    acc + 0.5
                }
            });

        let m = matches as f64;
        let t = transpositions;
        return JaroSimilarityResult {
            value: ((m / lens[0] as f64) + (m / lens[1] as f64) + ((m - t) / m)) / 3.0,
            max_prefix_length: last_matched_prefix_index + 1,
        };
    }
}

mod jaro_winkler {
    use crate::jaro;
    use std::cmp;

    pub fn similarity(
        a: &str,
        b: &str,
        ignore_case: bool,
        prefix_length: u32,
        prefix_scaling_factor: f64,
        prefix_scaling_bonus_threshold: f64,
    ) -> f64 {
        let jaro_similarity = jaro::similarity(a, b, ignore_case, true);
        let common_prefix_len = cmp::min(prefix_length as i64, jaro_similarity.max_prefix_length);

        if jaro_similarity.value > prefix_scaling_bonus_threshold {
            return jaro_similarity.value
                + common_prefix_len as f64 * prefix_scaling_factor * (1.0 - jaro_similarity.value);
        }
        return jaro_similarity.value;
    }
}

use libc::{c_char, c_double};
use std::ffi::CStr;

#[no_mangle]
pub extern "C" fn sorensen_dice_coefficient_c(
    a: *const c_char,
    b: *const c_char,
    ignore_case: c_char,
) -> c_double {
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
pub extern "C" fn jaro_similarity_c(
    a: *const c_char,
    b: *const c_char,
    ignore_case: c_char,
) -> c_double {
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

    return jaro::similarity(a_str, b_str, ignore_case == 1, true).value;
}

#[no_mangle]
pub extern "C" fn jaro_winkler_similarity_c(
    a: *const c_char,
    b: *const c_char,
    ignore_case: c_char,
    prefix_length: u32,
    prefix_scaling_factor: c_double,
    prefix_scaling_bonus_threshold: c_double,
) -> c_double {
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
        prefix_scaling_factor,
        prefix_scaling_bonus_threshold,
    );
}

#[no_mangle]
pub extern "C" fn jaro_winkler_distance_c(
    a: *const c_char,
    b: *const c_char,
    ignore_case: c_char,
    prefix_length: u32,
    prefix_scaling_factor: c_double,
    prefix_scaling_bonus_threshold: c_double,
) -> c_double {
    return 1.0
        - jaro_winkler_similarity_c(
            a,
            b,
            ignore_case,
            prefix_length,
            prefix_scaling_factor,
            prefix_scaling_bonus_threshold,
        );
}
