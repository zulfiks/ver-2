<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Food;

class FoodController extends Controller
{
    public function index()
    {
        $foods = Food::all(); // Mengambil semua data dari tabel foods
        return response()->json([
            'success' => true,
            'data' => $foods
        ], 200);
    }
}