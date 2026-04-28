import {
  IsString,
  IsNotEmpty,
  IsInt,
  IsPositive,
  IsDateString,
  MaxLength,
} from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateCattleDto {
  @ApiProperty({ example: 1 })
  @IsInt()
  @IsPositive()
  ownerId: number;

  @ApiProperty({ example: 'C-001' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  cattleUniqueId: string;

  @ApiProperty({ example: '2026-01-15' })
  @IsDateString()
  purchaseDate: string;

  @ApiProperty({ example: 50000 })
  @IsPositive()
  purchasePrice: number;
}
