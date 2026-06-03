<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class FoodLog extends Model
{
    protected $fillable = ['whatsapp_number', 'food_name', 'portion', 'calories'];
}