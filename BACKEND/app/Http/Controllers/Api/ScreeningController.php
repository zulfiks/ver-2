<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Screening;

class ScreeningController extends Controller
{
    public function store(Request $request)
    {
        $weight = (float) $request->weight;
        $height = (float) $request->height;
        $waist = (float) $request->waist;
        $age = (int) $request->age;
        $gender = strtolower($request->gender);

        $heightMeter = $height / 100;

        $imt = $weight / ($heightMeter * $heightMeter);

        // BMI
        if ($imt < 18.5) {

            $imtClass = 'Underweight';
            $riskLevel = 'Low';

        } elseif ($imt <= 22.9) {

            $imtClass = 'Normal';
            $riskLevel = 'Normal';

        } elseif ($imt <= 24.9) {

            $imtClass = 'Overweight';
            $riskLevel = 'Moderate';

        } elseif ($imt <= 29.9) {

            $imtClass = 'Obesity I';
            $riskLevel = 'High';

        } else {

            $imtClass = 'Obesity II';
            $riskLevel = 'Very High';
        }

        // Central obesity
        $isCentralObesity =
            ($gender == 'male' && $waist > 90) ||
            ($gender == 'female' && $waist > 80);

        $centralStatus =
            $isCentralObesity
                ? 'Central Obesity'
                : 'Normal';

        // =========================
        // AI PLAN
        // =========================

        $weeklyTarget =
            'Menjaga pola hidup sehat';

        $activityTarget =
            'Olahraga ringan';

        $foodRecommendation =
            'Perbanyak konsumsi sayur';

        $habitRecommendation =
            'Minum air putih cukup';

        if ($imt >= 25) {

            $weeklyTarget =
                'Turun 0.5 - 1 kg secara bertahap';

            $activityTarget =
                'Low impact cardio 30 menit';

            $foodRecommendation =
                'Kurangi makanan ultra processed';

            $habitRecommendation =
                'Hindari makan larut malam';
        }

        // SAVE
        $screening = $screening = new Screening();
        $screening->weight = $weight;
$screening->height = $height;
$screening->waist = $waist;
$screening->gender = $gender;

$screening->imt_value = round($imt, 1);
$screening->imt_classification = $imtClass;

$screening->risk_level = $riskLevel;
$screening->central_obesity_status = $centralStatus;

$screening->sarc_f_score = null;
$screening->sarcopenia_status = null;

$screening->save();

        return response()->json([
            'success' => true,
            'data' => $screening
        ]);
    }

    public function latest($user_id)
    {
        $latest = Screening::latest()->first();

        return response()->json([
            'success' => true,
            'data' => $latest
        ]);
    }
}