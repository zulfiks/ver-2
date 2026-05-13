<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;
use App\Models\Screening;

class FoodLogController extends Controller
{
    // Simpan makanan ke jurnal harian
    public function store(Request $request)
    {
        $request->validate([
            'user_id' => 'required',
            'food_id' => 'required',
            'porsi' => 'required',
            'total_kalori' => 'required'
        ]);

        $food = DB::table('foods')->where('id', $request->food_id)->first();
        $foodName = $food ? $food->name : 'Makanan Tidak Diketahui';

        DB::table('food_logs')->insert([
            'user_id' => $request->user_id,
            'food_id' => $request->food_id,
            'food_name' => $foodName,
            'portion' => $request->porsi,
            'total_calories' => $request->total_kalori,
            'log_date' => Carbon::now()->toDateString(),
            'created_at' => Carbon::now(),
            'updated_at' => Carbon::now()
        ]);

        return response()->json(['success' => true, 'message' => 'Berhasil disimpan!'], 201);
    }

    // Ambil data makan hari ini
    public function today($user_id)
    {
        $today = Carbon::now()->toDateString();
        
        $logs = DB::table('food_logs')
            ->where('user_id', $user_id)
            ->where('log_date', $today)
            ->orderBy('created_at', 'desc')
            ->get();

        $totalKalori = $logs->sum('total_calories'); 

        return response()->json([
            'success' => true,
            'total_kalori' => $totalKalori,
            'logs' => $logs
        ]);
    }

    // Ambil Analisis Kebiasaan (Obesity Risk Alert & Smart Reminder)
    public function getAnalysis($user_id)
    {
        $user = DB::table('users')->where('id', $user_id)->first();
        $firstName = $user ? explode(' ', $user->name)[0] : 'Pengguna';

        $sevenDaysAgo = Carbon::now()->subDays(7)->toDateString();

        // Deteksi minuman manis (Gula/Manis/Es Teh)
        $sweetDrinksCount = DB::table('food_logs')
            ->where('user_id', $user_id)
            ->where('log_date', '>=', $sevenDaysAgo)
            ->where(function($query) {
                $query->where('food_name', 'like', '%manis%')
                      ->orWhere('food_name', 'like', '%es teh%')
                      ->orWhere('food_name', 'like', '%kopi susu%')
                      ->orWhere('food_name', 'like', '%gula%');
            })->count();

        // Deteksi makan malam telat
        $lateNightMeals = DB::table('food_logs')
            ->where('user_id', $user_id)
            ->whereRaw('HOUR(created_at) >= 20')
            ->count();

        $alert = "";
        if ($sweetDrinksCount >= 4) {
            $alert = "Wah $firstName, dalam 7 hari ini kamu sudah $sweetDrinksCount kali konsumsi manis. Yuk, batasi dulu agar progresmu lancar! ✨";
        }

        $reminder = "Halo $firstName, jangan lupa minum air putih sebelum makan siang ya!";
        if ($lateNightMeals >= 3) {
            $reminder = "$firstName, coba majukan jam makan malammu sebelum jam 19.00 agar tidurmu lebih nyenyak.";
        }

        $latestScreening = Screening::latest()->first();

return response()->json([
    'success' => true,

    'alert_message' => $alert,
    'reminder_message' => $reminder,

    // AI PLAN
    'latest_screening' => $latestScreening,
]);
    }
}