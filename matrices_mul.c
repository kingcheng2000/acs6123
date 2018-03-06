#include <stdio.h>
int main(void) {
	int col_1,row_1,col_2,row_2,size_a,col_a,row_a,x;
	int a[3][4] = { 0 };
	int braitenberg_matrix[3][2] = {{150,-35},{100,-15},{80,-10}};
	int sensor_values[2][1] = {31,39 };

	size_a = sizeof(a);
	x = sizeof(a[0]);
	col_a = sizeof(a[0]) / sizeof(int);
	row_a = sizeof(a) / sizeof(a[0]);

	col_1 = sizeof(braitenberg_matrix[0])/sizeof(int);
	row_1 = sizeof(braitenberg_matrix) / sizeof(braitenberg_matrix[0]);

	col_2 = sizeof(sensor_values[0])/sizeof(int);
	row_2 = sizeof(sensor_values) / sizeof(sensor_values[0]);

	int i, j, k, matrix[3][1];
	for (i = 0; i < row_1; i++) {
		for (j = 0; j < col_2; j++) {
			matrix[i][j] = 0;
			for (k = 0; k < col_1; k++) 
			matrix[i][j] = matrix[i][j] + braitenberg_matrix[i][k] * sensor_values[k][j];
		}
	}
	for (i = 0; i < row_1; i++) {
		for (j = 0; j < col_2; j++) {
			printf("%d", matrix[i][j]);
		}
		printf("\n");
	}
	return 0;
}