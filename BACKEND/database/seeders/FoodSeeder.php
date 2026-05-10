<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Food;

class FoodSeeder extends Seeder
{
    public function run(): void
    {
        $foods = [
            ['name' => 'Nasi Padang (Ayam Pop)', 'calories' => 700, 'serving_size' => '1 Porsi'],
            ['name' => 'Nasi Pecel Madiun', 'calories' => 450, 'serving_size' => '1 Porsi'],
            ['name' => 'Bakso Sapi Urat', 'calories' => 380, 'serving_size' => '1 Mangkuk'],
            ['name' => 'Mie Ayam Pangsit', 'calories' => 420, 'serving_size' => '1 Mangkuk'],
            ['name' => 'Es Teh Manis', 'calories' => 85, 'serving_size' => '1 Gelas'],
            ['name' => 'Ayam Geprek & Nasi', 'calories' => 650, 'serving_size' => '1 Porsi'],
            ['name' => 'Gorengan (Bakwan/Tahu)', 'calories' => 140, 'serving_size' => '1 Potong'],
            ['name' => 'Seblak Kuah Pedas', 'calories' => 480, 'serving_size' => '1 Mangkuk'],
        ];

        foreach ($foods as $food) {
            Food::create($food);
        }
    }
}