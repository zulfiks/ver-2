<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class TaskSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
public function run(): void
{
    \App\Models\Task::create([
        'title' => 'Belajar Backend Laravel',
        'description' => 'Menyelesaikan setup awal API',
        'is_completed' => false
    ]);

    \App\Models\Task::create([
        'title' => 'Makan Siang',
        'description' => 'Makan nasi goreng di depan kampus',
        'is_completed' => true
    ]);
}
}
