use std::ops::Index;
use std::ops::IndexMut;

pub struct Array2D<T> {
    arr: Vec<T>,
    cols: usize,
}

impl<T: Clone + Default> Array2D<T> {
    pub fn new(rows: usize, columns: usize) -> Array2D<T> {
        Array2D {
            arr: vec![Default::default(); rows * columns],
            cols: columns,
        }
    }
}

impl<T> Index<(usize, usize)> for Array2D<T> {
    type Output = T;

    fn index(&self, (y, x): (usize, usize)) -> &Self::Output {
        &self.arr[y * self.cols + x]
    }
}

impl<T> IndexMut<(usize, usize)> for Array2D<T> {
    fn index_mut(&mut self, (y, x): (usize, usize)) -> &mut Self::Output {
        &mut self.arr[y * self.cols + x]
    }
}
