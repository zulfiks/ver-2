<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Screening;

class ScreeningController extends Controller
{
    public function store(Request $request)
    {
        // 1. Perhitungan IMT: Berat (kg) / Tinggi (m)^2 [cite: 275]
        $heightInMeters = $request->height / 100;
        $imt = $request->weight / ($heightInMeters * $heightInMeters);

        // 2. Klasifikasi IMT & Risiko Asia Pasifik (Tabel 3.1) [cite: 278]
        if ($imt < 18.5) {
            $class = "Berat badan kurang"; $risk = "Rendah";
        } elseif ($imt <= 22.9) {
            $class = "Normal"; $risk = "Rata-rata";
        } elseif ($imt <= 24.9) {
            $class = "Berat badan lebih"; $risk = "Meningkat";
        } elseif ($imt <= 29.9) {
            $class = "Obesitas I"; $risk = "Sedang";
        } else {
            $class = "Obesitas II"; $risk = "Berat";
        }

        // 3. Logika Obesitas Sentral: L > 90 cm, P > 80 cm [cite: 178, 285]
        $isCentral = ($request->gender == 'male' && $request->waist > 90) || 
                     ($request->gender == 'female' && $request->waist > 80);
        $centralStatus = $isCentral ? "Obesitas Sentral" : "Normal";

        // 4. Logika Sarkopenia SARC-F: Skor >= 4 [cite: 181, 493]
        $sarcStatus = ($request->sarc_f_score >= 4) ? "Kemungkinan Sarkopenia" : "Normal";

        // Simpan hasil ke database sesuai tabel yang kamu buat
        $screening = Screening::create([
            'weight' => $request->weight,
            'height' => $request->height,
            'gender' => $request->gender,
            'waist' => $request->waist,
            'sarc_f_score' => $request->sarc_f_score,
            'imt_value' => round($imt, 2),
            'imt_classification' => $class,
            'risk_level' => $risk,
            'central_obesity_status' => $centralStatus,
            'sarcopenia_status' => $sarcStatus
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Analisis sesuai KMK No. 509 Tahun 2025',
            'data' => $screening
        ]);
    }
}