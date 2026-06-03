<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class FoodLogController extends Controller
{
    /**
     * API KHUSUS: Menerima & memproses input dari Volt Agent (WhatsApp)
     * Alur: Volt kirim teks makanan -> Laravel cari di DB -> Jika ada pakai kalori DB, jika tidak pakai kalori AI
     */
    public function storeFromWhatsApp(Request $request)
    {
        // 1. Validasi data masuk dari Volt Agent
        $request->validate([
            'whatsapp_number' => 'required',
            'makanan_input'   => 'required|string',
            'porsi'           => 'required',
            'estimasi_kalori_ai' => 'required|integer' // Estimasi cadangan dari LLM Volt
        ]);

        // 2. Cari user berdasarkan nomor WhatsApp
        $user = DB::table('users')
            ->where('phone_number', 'like', '%' . $request->whatsapp_number . '%')
            ->first();

        // Jika nomor WA tidak terdaftar, gunakan ID default (misal: 1) agar sistem tidak crash
        $userId = $user ? $user->id : 1;

        // 3. Cari makanan di database lokal Indonesia (Food Matching)
        $food = DB::table('foods')
            ->where('nama_makanan', 'like', '%' . $request->makanan_input . '%')
            ->first();

        if ($food) {
            // JIKA COCOK: Gunakan ID makanan asli dan hitung kalori dari database
            $foodId = $food->id;
            $totalKalori = $food->kalori * (float)$request->porsi;
            $matchStatus = "Matched with Database";
        } else {
            // JIKA TIDAK COCOK (Unknown Food): Gunakan ID default/NULL, kalori pakai hitungan LLM Volt
            $foodId = 1; // Pastikan ada ID 1 dengan nama "Makanan Lainnya/Estimasi AI" di tabel foods kamu
            $totalKalori = $request->estimasi_kalori_ai;
            $matchStatus = "Estimated by AI (Food Not Found in DB)";
        }

        $waktuMakan = Carbon::now()->toTimeString();
        $tanggalCatat = Carbon::now()->toDateString();

        // 4. Simpan ke Serial DB (Tabel food_logs)
        DB::table('food_logs')->insert([
            'user_id'       => $userId,
            'food_id'       => $foodId,
            'porsi'         => $request->porsi,
            'total_kalori'  => $totalKalori,
            'waktu_makan'   => $waktuMakan,
            'tanggal_catat' => $tanggalCatat,
            'created_at'    => Carbon::now(),
            'updated_at'    => Carbon::now()
        ]);

        // 5. Beri respon balik ke Volt Agent untuk dikirim sebagai chat balasan WA ke user
        return response()->json([
            'success'      => true,
            'message'      => 'Berhasil dicatat lewat WhatsApp!',
            'match_status' => $matchStatus,
            'data' => [
                'user_id'      => $userId,
                'makanan'      => $food ? $food->nama_makanan : $request->makanan_input,
                'porsi'        => $request->porsi,
                'total_kalori' => $totalKalori
            ]
        ], 201);
    }

    // ==========================================
    // FUNGSI BAWAANMU (YANG SUDAH ADA SEBELUMNYA)
    // ==========================================

    // Simpan makanan ke jurnal harian via Web/Manual
    public function store(Request $request)
    {
        $request->validate([
            'user_id' => 'required',
            'food_id' => 'required',
            'porsi' => 'required',
            'total_kalori' => 'required'
        ]);

        $waktuMakan = $request->input('waktu_makan', Carbon::now()->toTimeString());
        $tanggalCatat = $request->input('tanggal_catat', Carbon::now()->toDateString());

        DB::table('food_logs')->insert([
            'user_id' => $request->user_id,
            'food_id' => $request->food_id,
            'porsi' => $request->porsi,
            'total_kalori' => $request->total_kalori,
            'waktu_makan' => $waktuMakan,
            'tanggal_catat' => $tanggalCatat,
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
            ->join('foods', 'food_logs.food_id', '=', 'foods.id')
            ->select('food_logs.*', 'foods.nama_makanan')
            ->where('food_logs.user_id', $user_id)
            ->where('food_logs.tanggal_catat', $today)
            ->orderBy('food_logs.created_at', 'desc')
            ->get();

        $totalKalori = $logs->sum('total_kalori'); 

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

        $sweetDrinksCount = DB::table('food_logs')
            ->join('foods', 'food_logs.food_id', '=', 'foods.id')
            ->where('food_logs.user_id', $user_id)
            ->where('food_logs.tanggal_catat', '>=', $sevenDaysAgo)
            ->where(function($query) {
                $query->where('foods.nama_makanan', 'like', '%manis%')
                      ->orWhere('foods.nama_makanan', 'like', '%es teh%')
                      ->orWhere('foods.nama_makanan', 'like', '%kopi susu%')
                      ->orWhere('foods.nama_makanan', 'like', '%gula%');
            })->count();

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

        return response()->json([
            'success' => true,
            'alert_message' => $alert,
            'reminder_message' => $reminder
        ]);
    }

    // Mencari makanan berdasarkan nama
    public function searchFood(Request $request)
    {
        $query = $request->query('query');
        
        if (!$query) {
            return response()->json(['success' => false, 'message' => 'Query pencarian kosong'], 400);
        }

        $foods = DB::table('foods')
            ->where('nama_makanan', 'like', '%' . $query . '%')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $foods
        ]);
    }
}