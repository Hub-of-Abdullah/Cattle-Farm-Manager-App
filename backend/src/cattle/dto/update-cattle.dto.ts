import { IsDateString, IsOptional, IsPositive } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateCattleDto {
  @ApiPropertyOptional({ example: '2026-01-16' })
  @IsOptional()
  @IsDateString()
  purchaseDate?: string;

  @ApiPropertyOptional({ example: 52000 })
  @IsOptional()
  @IsPositive()
  purchasePrice?: number;
}
