/* Copyright 2012 Jun Wako <wakojun@gmail.com>
 * Copyright 2013 Oleg Kostyuk <cub.uanic@gmail.com>
 * Copyright 2015 ZSA Technology Labs Inc (@zsa)
 * Copyright 2020 Christopher Courtney <drashna@live.com> (@drashna)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#pragma once

#define ORYX_CONFIGURATOR

/*
 * Leader key
 */

#define LEADER_TIMEOUT 500
#define LEADER_PER_KEY_TIMING

/*
 * Debouncing delay
 */

#define DEBOUNCING_DELAY 10

/*
 * Hold-tap timeout
 */

#define TAPPING_TERM 250