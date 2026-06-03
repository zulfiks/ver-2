<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Screening extends Model
{
    use HasFactory;

protected $fillable = [

    'weight',
    'height',
    'waist',
    'age',
    'gender',

    'imt_value',
    'imt_classification',

    'risk_level',
    'central_obesity_status',
    'sarc_f_score',
    'sarcopenia_status',

    // AI PLAN
    'weekly_target',
    'activity_target',
    'food_recommendation',
    'habit_recommendation',
];
}