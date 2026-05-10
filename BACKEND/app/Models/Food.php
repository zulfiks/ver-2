<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Food extends Model
{
    // Tambahkan baris ini untuk memaksa Laravel menggunakan tabel 'foods'
    protected $table = 'foods'; 

    protected $fillable = ['nama_makanan', 'kalori_standar', 'satuan_standar'];
}