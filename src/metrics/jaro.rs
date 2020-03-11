use crate::metrics::utils::graphemes;
use std::cmp;

pub struct JaroSimilarityResult {
    pub value: f64,
    pub max_prefix_length: i64,
}

pub fn similarity(a: &str, b: &str, ignore_case: bool) -> JaroSimilarityResult {
    if ignore_case {
        return similarity_impl(&graphemes(&a.to_lowercase()), &graphemes(&b.to_lowercase()));
    }

    similarity_impl(&graphemes(a), &graphemes(b))
}

fn similarity_impl<T: Eq>(a: &[T], b: &[T]) -> JaroSimilarityResult {
    let mut graphemes = [a, b];
    if graphemes[0].len() > graphemes[1].len() {
        graphemes.swap(0, 1);
    }

    // let grapheme_iterators = [UnicodeSegmentation::graphemes(&case_handled[0][..], true), UnicodeSegmentation::graphemes(&case_handled[1][..], true)];
    let lens = [graphemes[0].len(), graphemes[1].len()];

    let max_length = cmp::max(lens[0], lens[1]);
    let matching_dist = if max_length < 2 {
        0
    } else {
        (max_length / 2) - 1
    };

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

            for (j, matched) in b_matched.iter_mut().enumerate().take(end).skip(start) {
                if grapheme == &graphemes[1][j] && !*matched {
                    *matched = true;
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
    JaroSimilarityResult {
        value: ((m / lens[0] as f64) + (m / lens[1] as f64) + ((m - t) / m)) / 3.0,
        max_prefix_length: last_matched_prefix_index + 1,
    }
}
