<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Food;
use Illuminate\Http\Request;

class FoodController extends Controller
{
    public function index(Request $request)
    {
        // Menambahkan pengecekan input 'search' secara opsional tanpa merusak fungsi Route::get('/foods') bawaan.
        // Jika dipanggil dari Go dengan parameter (?search=nama), block ini akan tereksekusi.
        if ($request->has('search')) {
            $search = $request->query('search');
            $food = Food::where('nama_makanan', 'like', '%' . $search . '%')->first();

            if (!$food) {
                return response()->json(['message' => 'Makanan tidak ditemukan'], 404);
            }

            // Langsung kembalikan satu objek single item untuk dibaca oleh Struct Go
            return response()->json([
                'id' => $food->id,
                'nama_makanan' => $food->nama_makanan,
                'kalori_standar' => $food->kalori_standar
            ], 200);
        }

        // FUNGSI ASLI: Mengambil semua data dari tabel foods (jika dipanggil tanpa ?search=)
        $foods = Food::all(); 
        return response()->json([
            'success' => true,
            'data' => $foods
        ], 200);
    }
}