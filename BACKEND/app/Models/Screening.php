<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Screening extends Model
{
    use HasFactory;

    protected $fillable = [
        'weight', 'height', 'gender', 'waist', 'sarc_f_score', 
        'imt_value', 'imt_classification', 'risk_level', 
        'central_obesity_status', 'sarcopenia_status'
    ];
}