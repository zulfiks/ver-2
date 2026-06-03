<?php

use App\Http\Controllers\Api\AuthController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\FoodController;
use App\Http\Controllers\Api\FoodLogController;
use App\Http\Controllers\Api\ScreeningController;;
use App\Http\Controllers\Api\LeaderboardController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::get('/foods', [FoodController::class, 'index']);
Route::post('/food-logs', [FoodLogController::class, 'store']);
Route::get('/leaderboard/top', [FoodLogController::class, 'leaderboard']);
Route::get('/food-logs/today/{user_id}', [FoodLogController::class, 'today']);
Route::post('/screening', [ScreeningController::class, 'store']);
Route::post('/user/{id}/upload-profile-picture', [AuthController::class, 'updateProfilePicture']);
Route::get('/leaderboard/top', [LeaderboardController::class, 'getTopLeaderboard']);
Route::get('/foods/search', [App\Http\Controllers\Api\FoodLogController::class, 'searchFood']);
Route::get('/foods/search', [FoodLogController::class, 'searchFood']);
Route::post('/food-log/whatsapp', [FoodLogController::class, 'storeFromWhatsApp']);