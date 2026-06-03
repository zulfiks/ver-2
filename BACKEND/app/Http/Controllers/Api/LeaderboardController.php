<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;

class LeaderboardController extends Controller
{
    public function getTopLeaderboard()
    {
        try {
            // Ambil data user beserta total kalori dari food_logs
            // Pastikan kolom 'profile_picture' ikut diseleksi
            $leaderboard = User::select('id', 'name', 'profile_picture')
                ->withSum('foodLogs as skor', 'total_kalori') // Sesuaikan 'foodLogs' dengan nama relasi di model User-mu
                ->orderBy('skor', 'desc')
                ->take(5) // Mengambil Top 5 sesuai UI Flutter
                ->get()
                ->map(function ($user) {
                    return [
                        'id' => $user->id,
                        'name' => $user->name,
                        'skor' => $user->skor ?? 0,
                        // Konversi path storage menjadi URL penuh agar bisa dibaca NetworkImage di Flutter
                        'profile_picture' => $user->profile_picture ? asset('storage/' . $user->profile_picture) : null,
                    ];
                });

            return response()->json([
                'success' => true,
                'leaderboard' => $leaderboard
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data leaderboard: ' . $e->getMessage()
            ], 500);
        }
    }
}