use crate::metrics::jaro;
use std::cmp;

pub fn similarity(
    a: &str,
    b: &str,
    ignore_case: bool,
    prefix_length: u32,
    prefix_scaling_factor: f64,
    prefix_scaling_bonus_threshold: f64,
) -> f64 {
    let jaro_similarity = jaro::similarity(a, b, ignore_case);
    let common_prefix_len = cmp::min(prefix_length as i64, jaro_similarity.max_prefix_length);

    if jaro_similarity.value > prefix_scaling_bonus_threshold {
        return jaro_similarity.value
            + common_prefix_len as f64 * prefix_scaling_factor * (1.0 - jaro_similarity.value);
    }
    jaro_similarity.value
}
