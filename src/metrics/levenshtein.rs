use crate::metrics::utils::graphemes;
use std::cmp;

pub fn distance(a: &str, b: &str, ignore_case: bool) -> i64 {
    if ignore_case {
        let case_ignored = [a.to_lowercase(), b.to_lowercase()];
        let graphemes = [graphemes(&case_ignored[0]), graphemes(&case_ignored[1])];
        return distance_impl(&graphemes[0], &graphemes[1]);
    }

    let graphemes = [graphemes(&a), graphemes(b)];
    return distance_impl(&graphemes[0], &graphemes[1]);
}

fn distance_impl<T: Eq>(a: &Vec<T>, b: &Vec<T>) -> i64 {
    let lens = [a.len(), b.len()];
    if lens[0] == 0 {
        return lens[1] as i64;
    }
    if lens[1] == 0 {
        return lens[0] as i64;
    }

    let rows = lens[0] + 1;
    let columns = lens[1] + 1;

    let mut base_vec = vec![0; rows * columns];
    let mut dist_matrix = base_vec.chunks_mut(columns).collect::<Vec<&mut [i64]>>();

    for i in 0..rows {
        dist_matrix[i][0] = i as i64;
    }
    for j in 0..columns {
        dist_matrix[0][j] = j as i64;
    }

    for i in 1..rows {
        for j in 1..columns {
            let cost = match a[i - 1] == b[j - 1] {
                true => 0,
                false => 1,
            };

            dist_matrix[i][j] = cmp::min(
                cmp::min(dist_matrix[i - 1][j] + 1, dist_matrix[i][j - 1] + 1),
                dist_matrix[i - 1][j - 1] + cost,
            );
        }
    }

    return dist_matrix[rows - 1][columns - 1];
}
