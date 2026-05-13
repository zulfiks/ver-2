<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Screening;

class ScreeningController extends Controller
{
    public function store(Request $request)
    {
        try {

            $data = $request->all();

            // =========================
            // BODY DATA
            // =========================

            $weight = (float) ($data['weight'] ?? 0);
            $height = (float) ($data['height'] ?? 0);
            $waist  = (float) ($data['waist'] ?? 0);
            $age    = (int) ($data['age'] ?? 0);

            $gender = strtolower($data['gender'] ?? 'male');

            // =========================
            // LIFESTYLE
            // =========================

            $activityLevel = $data['activity_level'] ?? '';
            $sweetDrink = $data['sweet_drink'] ?? '';
            $fastFood = $data['fast_food'] ?? '';
            $sleepDuration = $data['sleep_duration'] ?? '';
            $fatigue = $data['fatigue'] ?? '';

            // =========================
            // VALIDATION
            // =========================

            if ($weight <= 0 || $height <= 0) {

                return response()->json([
                    'status' => 'error',
                    'message' => 'Data tidak valid'
                ], 400);
            }

            // =========================
            // BMI
            // =========================

            $heightMeter = $height / 100;

            $imt = $weight / ($heightMeter * $heightMeter);

            // =========================
            // BMI CLASSIFICATION
            // =========================

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

            // =========================
            // CENTRAL OBESITY
            // =========================

            $isMale = in_array($gender, [
                'male',
                'laki-laki'
            ]);

            $isCentralObesity =
                ($isMale && $waist > 90) ||
                (!$isMale && $waist > 80);

            $centralStatus = $isCentralObesity
                ? 'Central Obesity'
                : 'Normal';

            // =========================
            // AI RECOMMENDATION ENGINE
            // =========================

            $weeklyTarget = 'Menjaga pola hidup sehat';
            $activityTarget = 'Olahraga ringan 20 menit';
            $foodRecommendation = 'Perbanyak konsumsi sayur';
            $habitRecommendation = 'Minum air putih cukup';

            // BMI tinggi
            if ($imt >= 25) {

                $weeklyTarget = 'Turun 0.5 - 1 kg secara bertahap';
                $activityTarget = 'Jalan kaki 30 menit setiap hari';
                $foodRecommendation = 'Kurangi makanan tinggi lemak dan gula';
                $habitRecommendation = 'Hindari makan larut malam';
            }

            // Fast food sering
            if ($fastFood == 'Sering') {

                $foodRecommendation = 'Batasi fast food maksimal 1x per minggu';
            }

            // Minuman manis sering
            if ($sweetDrink == 'Sering') {

                $habitRecommendation = 'Kurangi konsumsi minuman manis';
            }

            // Aktivitas rendah
            if ($activityLevel == 'Jarang') {

                $activityTarget = 'Mulai aktivitas fisik ringan 20-30 menit';
            }

            // Kurang tidur
            if ($sleepDuration == '<5 jam') {

                $habitRecommendation = 'Tidur minimal 7 jam per hari';
            }

            // Fatigue
            if ($fatigue == 'Ya') {

                $activityTarget = 'Lakukan olahraga ringan dan istirahat cukup';
            }

            // =========================
            // SAVE
            // =========================

            $screening = new Screening();

            $screening->weight = $weight;
            $screening->height = $height;
            $screening->waist = $waist;
            $screening->age = $age;
            $screening->gender = $gender;

            $screening->imt_value = round($imt, 1);
            $screening->imt_classification = $imtClass;

            $screening->risk_level = $riskLevel;
            $screening->central_obesity_status = $centralStatus;

            // AI PLAN
            $screening->weekly_target = $weeklyTarget;
            $screening->activity_target = $activityTarget;
            $screening->food_recommendation = $foodRecommendation;
            $screening->habit_recommendation = $habitRecommendation;

            $screening->save();

            // =========================
            // RESPONSE
            // =========================

            return response()->json([
                'status' => 'success',
                'data' => [

                    'imt_value' => round($imt, 1),
                    'imt_classification' => $imtClass,

                    'overall_risk' => $riskLevel,
                    'central_obesity_status' => $centralStatus,

                    // AI PLAN
                    'weekly_target' => $weeklyTarget,
                    'activity_target' => $activityTarget,
                    'food_recommendation' => $foodRecommendation,
                    'habit_recommendation' => $habitRecommendation,
                ]
            ], 200);

        } catch (\Exception $e) {

            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage(),
            ], 500);
        }
    }
}