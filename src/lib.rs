mod metrics;

use libc::{c_char, c_double};
use std::ffi::CStr;

fn cstr_from_raw(s: &*const c_char) -> &CStr {
    unsafe { CStr::from_ptr(*s) }
}

#[no_mangle]
pub extern "C" fn sorensen_dice_coefficient(
    a: *const c_char,
    b: *const c_char,
    ignore_case: c_char,
) -> c_double {
    if a.is_null() || b.is_null() {
        return 0.0;
    }

    let a_c_str = cstr_from_raw(&a);
    let b_c_str = cstr_from_raw(&b);

    let a_str = match a_c_str.to_str() {
        Err(_e) => return 0.0,
        Ok(s) => s,
    };

    let b_str = match b_c_str.to_str() {
        Err(_e) => return 0.0,
        Ok(s) => s,
    };

    metrics::sorensen_dice::coefficient(a_str, b_str, ignore_case == 1)
}

#[no_mangle]
pub extern "C" fn jaro_similarity(
    a: *const c_char,
    b: *const c_char,
    ignore_case: c_char,
) -> c_double {
    if a.is_null() || b.is_null() {
        return 0.0;
    }

    let a_c_str = cstr_from_raw(&a);
    let b_c_str = cstr_from_raw(&b);

    let a_str = match a_c_str.to_str() {
        Err(_e) => return 0.0,
        Ok(s) => s,
    };

    let b_str = match b_c_str.to_str() {
        Err(_e) => return 0.0,
        Ok(s) => s,
    };

    metrics::jaro::similarity(a_str, b_str, ignore_case == 1).value
}

#[no_mangle]
pub extern "C" fn jaro_winkler_similarity(
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

    let a_c_str = cstr_from_raw(&a);
    let b_c_str = cstr_from_raw(&b);

    let a_str = match a_c_str.to_str() {
        Err(_e) => return 0.0,
        Ok(s) => s,
    };

    let b_str = match b_c_str.to_str() {
        Err(_e) => return 0.0,
        Ok(s) => s,
    };

    metrics::jaro_winkler::similarity(
        a_str,
        b_str,
        ignore_case == 1,
        prefix_length,
        prefix_scaling_factor,
        prefix_scaling_bonus_threshold,
    )
}

#[no_mangle]
pub extern "C" fn jaro_winkler_distance(
    a: *const c_char,
    b: *const c_char,
    ignore_case: c_char,
    prefix_length: u32,
    prefix_scaling_factor: c_double,
    prefix_scaling_bonus_threshold: c_double,
) -> c_double {
    1.0 - jaro_winkler_similarity(
        a,
        b,
        ignore_case,
        prefix_length,
        prefix_scaling_factor,
        prefix_scaling_bonus_threshold,
    )
}

#[no_mangle]
pub extern "C" fn levenshtein_distance(
    a: *const c_char,
    b: *const c_char,
    ignore_case: c_char,
) -> i64 {
    if a.is_null() || b.is_null() {
        return std::i64::MAX;
    }

    let a_c_str = cstr_from_raw(&a);
    let b_c_str = cstr_from_raw(&b);

    let a_str = match a_c_str.to_str() {
        Err(_e) => return std::i64::MAX,
        Ok(s) => s,
    };

    let b_str = match b_c_str.to_str() {
        Err(_e) => return std::i64::MAX,
        Ok(s) => s,
    };

    metrics::levenshtein::distance(a_str, b_str, ignore_case == 1)
}

#[no_mangle]
pub extern "C" fn damerau_levenshtein_distance(
    a: *const c_char,
    b: *const c_char,
    ignore_case: c_char,
) -> i64 {
    if a.is_null() || b.is_null() {
        return std::i64::MAX;
    }

    let a_c_str = cstr_from_raw(&a);
    let b_c_str = cstr_from_raw(&b);

    let a_str = match a_c_str.to_str() {
        Err(_e) => return std::i64::MAX,
        Ok(s) => s,
    };

    let b_str = match b_c_str.to_str() {
        Err(_e) => return std::i64::MAX,
        Ok(s) => s,
    };

    metrics::damerau_levenshtein::distance(a_str, b_str, ignore_case == 1)
}
