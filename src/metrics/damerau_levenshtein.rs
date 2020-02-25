use crate::metrics::utils::graphemes;
use crate::metrics::utils::Array2D;

use std::cmp;
use std::collections::HashMap;
use std::hash::Hash;

pub fn distance(a: &str, b: &str, ignore_case: bool) -> i64 {
    if ignore_case {
        return distance_impl(&graphemes(&a.to_lowercase()), &graphemes(&b.to_lowercase()));
    }

    distance_impl(&graphemes(a), &graphemes(b))
}

// From https://en.wikipedia.org/wiki/Damerau-Levenshtein_distance
fn distance_impl<T: Hash + Eq>(a: &Vec<T>, b: &Vec<T>) -> i64 {
    let lens = [a.len(), b.len()];
    if lens[0] == 0 {
        return lens[1] as i64;
    }
    if lens[1] == 0 {
        return lens[0] as i64;
    }

    let rows = lens[0] + 2;
    let columns = lens[1] + 2;

    let max_dist = (lens[0] + lens[1]) as i64;
    let mut dist_matrix = Array2D::new(rows, columns);

    dist_matrix[(0, 0)] = max_dist;
    for i in 1..rows {
        dist_matrix[(i, 0)] = max_dist;
        dist_matrix[(i, 1)] = (i - 1) as i64;
    }
    for j in 1..columns {
        dist_matrix[(0, j)] = max_dist;
        dist_matrix[(1, j)] = (j - 1) as i64;
    }

    let mut da: HashMap<&T, usize> = HashMap::new();

    for i in 1..lens[0] + 1 {
        let mut db = 0;
        for j in 1..lens[1] + 1 {
            let k = da.entry(&b[j - 1]).or_insert(0);
            let l = db;
            let cost = match a[i - 1] == b[j - 1] {
                true => {
                    db = j;
                    0
                }
                false => 1,
            };

            dist_matrix[(i + 1, j + 1)] = cmp::min(
                dist_matrix[(i, j)] + cost,
                cmp::min(
                    dist_matrix[(i + 1, j)] + 1,
                    cmp::min(
                        dist_matrix[(i, j + 1)] + 1,
                        dist_matrix[(*k, l)] + (i - *k - 1) as i64 + 1 + (j - l - 1) as i64,
                    ),
                ),
            );
        }
        da.insert(&a[i - 1], i);
    }

    dist_matrix[(lens[0] + 1, lens[1] + 1)]
}
