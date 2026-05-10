<?php

use App\Http\Controllers\Api\AuthController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\FoodController;
use App\Http\Controllers\Api\FoodLogController;
use App\Http\Controllers\Api\ScreeningController;;


Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::get('/foods', [FoodController::class, 'index']);
Route::post('/food-logs', [FoodLogController::class, 'store']);
Route::get('/food-logs/today/{user_id}', [FoodLogController::class, 'today']);
Route::post('/screening', [ScreeningController::class, 'store']);
